import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_model.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Storage bucket name
  static const String mediaBucket = 'media';
  static const String thumbnailsPath = 'thumbnails';
  static const String videosPath = 'videos';

  // ========================================================================
  // VIDEO QUERIES
  // ========================================================================

  /// Get live channels as a stream (real-time updates)
  Stream<List<VideoModel>> getLiveChannels() {
    return _supabase
        .from('videos')
        .stream(primaryKey: ['id'])
        .eq('is_live', true)
        .order('upload_date', ascending: false)
        .map((data) {
          print('🔴 LIVE CHANNELS: Found ${data.length} documents');
          return data.map((json) {
            print('📺 Channel: ${json['title']} | is_live: ${json['is_live']}');
            return VideoModel.fromMap(json);
          }).toList();
        });
  }

  /// Get archive videos as a stream
  Stream<List<VideoModel>> getArchiveVideos({String? category}) {
    var query = _supabase
        .from('videos')
        .stream(primaryKey: ['id'])
        .eq('is_live', false)
        .order('upload_date', ascending: false);

    return query.map((data) {
      print('📚 ARCHIVE: Found ${data.length} documents (category: ${category ?? "All"})');
      
      var videos = data.map((json) {
        return VideoModel.fromMap(json);
      }).toList();

      // Filter by category if provided (since Supabase streams don't support multiple filters)
      if (category != null && category != 'All') {
        videos = videos.where((v) => v.category == category).toList();
      }

      print('✅ Converted to ${videos.length} VideoModel objects');
      return videos;
    });
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('videos')
          .select('category')
          .order('category');

      final categories = response
          .map((row) => row['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      return ['All', ...categories];
    } catch (e) {
      print('Error fetching categories: $e');
      return ['All'];
    }
  }

  /// Get featured/hero live stream
  Future<VideoModel?> getFeaturedLiveStream() async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .eq('is_live', true)
          .eq('featured', true)
          .order('upload_date', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return VideoModel.fromMap(response.first);
      }

      // If no featured, return first live stream
      final fallbackResponse = await _supabase
          .from('videos')
          .select()
          .eq('is_live', true)
          .order('upload_date', ascending: false)
          .limit(1);

      if (fallbackResponse.isNotEmpty) {
        return VideoModel.fromMap(fallbackResponse.first);
      }

      return null;
    } catch (e) {
      print('Error fetching featured stream: $e');
      return null;
    }
  }

  /// Get viewer count for a video (real-time)
  Stream<int> getViewerCount(String videoId) {
    return _supabase
        .from('videos')
        .stream(primaryKey: ['id'])
        .eq('id', videoId)
        .map((data) {
          if (data.isNotEmpty) {
            return data.first['viewers'] ?? 0;
          }
          return 0;
        });
  }

  /// Increment viewer count
  Future<void> incrementViewerCount(String videoId) async {
    try {
      // Get current viewers
      final response = await _supabase
          .from('videos')
          .select('viewers')
          .eq('id', videoId)
          .single();

      final currentViewers = response['viewers'] ?? 0;

      // Update with incremented value
      await _supabase
          .from('videos')
          .update({'viewers': currentViewers + 1})
          .eq('id', videoId);
    } catch (e) {
      print('Error incrementing viewer count: $e');
    }
  }

  // ========================================================================
  // FILE UPLOAD (Storage)
  // ========================================================================

  /// Upload file to Supabase Storage and return public URL
  /// 
  /// [file] - The file to upload
  /// [path] - Storage path (e.g., 'thumbnails' or 'videos')
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  Future<String> uploadFile({
    required File file,
    required String path,
    Function(double progress)? onProgress,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storagePath = '$path/$fileName';

      print('📤 Uploading to: $storagePath');

      // Upload file to Supabase Storage
      final uploadPath = await _supabase.storage
          .from(mediaBucket)
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              upsert: false,
            ),
          );

      print('✅ Upload complete: $uploadPath');

      // Get public URL
      final publicUrl = _supabase.storage
          .from(mediaBucket)
          .getPublicUrl(storagePath);

      print('🔗 Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload image (thumbnail/logo)
  Future<String> uploadThumbnail(File file, {Function(double)? onProgress}) async {
    return uploadFile(
      file: file,
      path: thumbnailsPath,
      onProgress: onProgress,
    );
  }

  /// Upload video file
  Future<String> uploadVideo(File file, {Function(double)? onProgress}) async {
    return uploadFile(
      file: file,
      path: videosPath,
      onProgress: onProgress,
    );
  }

  // ========================================================================
  // VIDEO CRUD OPERATIONS
  // ========================================================================

  /// Add a new video to the database
  Future<void> addVideo({
    required String title,
    required String url,
    required String thumbnailUrl,
    String? logoUrl,
    required String category,
    required String duration,
    String? description,
    required bool isLive,
    bool featured = false,
  }) async {
    try {
      await _supabase.from('videos').insert({
        'title': title,
        'description': description ?? '',
        'url': url,
        'thumbnail_url': thumbnailUrl,
        'logo_url': logoUrl,
        'category': category,
        'duration': duration,
        'upload_date': DateTime.now().toIso8601String(),
        'is_live': isLive,
        'featured': featured,
        'viewers': 0,
      });

      print('✅ Video added successfully');
    } catch (e) {
      print('❌ Error adding video: $e');
      throw Exception('Failed to add video: $e');
    }
  }

  /// Update a video
  Future<void> updateVideo(String videoId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('videos')
          .update(updates)
          .eq('id', videoId);

      print('✅ Video updated successfully');
    } catch (e) {
      print('❌ Error updating video: $e');
      throw Exception('Failed to update video: $e');
    }
  }

  /// Delete a video and its associated files from storage
  Future<void> deleteVideo(String videoId, {String? videoUrl, String? thumbnailUrl}) async {
    try {
      // Delete from database
      await _supabase
          .from('videos')
          .delete()
          .eq('id', videoId);

      // Try to delete associated files from storage
      if (videoUrl != null) {
        await _deleteStorageFile(videoUrl);
      }
      if (thumbnailUrl != null) {
        await _deleteStorageFile(thumbnailUrl);
      }

      print('✅ Video deleted successfully');
    } catch (e) {
      print('❌ Error deleting video: $e');
      throw Exception('Failed to delete video: $e');
    }
  }

  /// Delete a file from Supabase Storage (helper method)
  Future<void> _deleteStorageFile(String fileUrl) async {
    try {
      // Extract the path from the public URL
      // Example URL: https://xxx.supabase.co/storage/v1/object/public/media/thumbnails/file.jpg
      // We need: thumbnails/file.jpg
      
      if (!fileUrl.contains('supabase.co/storage')) {
        print('ℹ️ File not in Supabase storage, skipping deletion');
        return;
      }

      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the index of 'media' bucket in path
      final bucketIndex = pathSegments.indexOf(mediaBucket);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        print('ℹ️ Could not extract storage path from URL');
        return;
      }

      // Get everything after the bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      await _supabase.storage.from(mediaBucket).remove([filePath]);
      print('🗑️ Deleted file from storage: $filePath');
    } catch (e) {
      print('⚠️ Could not delete storage file: $e');
      // Don't throw - we don't want to fail the whole deletion if storage cleanup fails
    }
  }

  /// Get all videos (for admin management)
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .order('upload_date', ascending: false);

      return response.map<VideoModel>((json) => VideoModel.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error fetching all videos: $e');
      throw Exception('Failed to fetch videos: $e');
    }
  }

  // ========================================================================
  // DEBUG/TEST
  // ========================================================================

  /// Test Supabase connection
  Future<void> testConnection() async {
    try {
      print('🔍 Testing Supabase connection...');
      
      final response = await _supabase
          .from('videos')
          .select()
          .limit(10);

      print('✅ Total documents in collection: ${response.length}');
      
      // Show ALL documents
      for (var doc in response) {
        print('📄 Document ID: ${doc['id']}');
        print('   - title: ${doc['title']}');
        print('   - is_live: ${doc['is_live']} (type: ${doc['is_live'].runtimeType})');
        print('   - category: ${doc['category']}');
        print('---');
      }
      
      // Count live vs archive
      final liveCount = response.where((doc) => doc['is_live'] == true).length;
      final archiveCount = response.where((doc) => doc['is_live'] == false).length;
      
      print('📊 Summary:');
      print('   🔴 Live channels: $liveCount');
      print('   📚 Archive videos: $archiveCount');
      
    } catch (e) {
      print('❌ ERROR: $e');
      print('---');
      print('Possible causes:');
      print('1. Supabase URL/Key incorrect');
      print('2. Table "videos" does not exist');
      print('3. RLS policies blocking access');
      print('4. No internet connection');
    }
  }
}
