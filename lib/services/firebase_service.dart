import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_model.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get live channels as a stream (real-time updates)
  Stream<List<VideoModel>> getLiveChannels() {
    return _firestore
        .collection('videos')
        .where('isLive', isEqualTo: true)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      print('🔴 LIVE CHANNELS: Found ${snapshot.docs.length} documents');
      
      final channels = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('📺 Channel: ${data['title']} | isLive: ${data['isLive']}');
        return VideoModel.fromFirestore(doc);
      }).toList();
      
      print('✅ Converted to ${channels.length} VideoModel objects');
      return channels;
    });
  }

  // Get archive videos as a stream
  Stream<List<VideoModel>> getArchiveVideos({String? category}) {
    Query query = _firestore
        .collection('videos')
        .where('isLive', isEqualTo: false)
        .orderBy('uploadDate', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      print('📚 ARCHIVE: Found ${snapshot.docs.length} documents (category: ${category ?? "All"})');
      
      final videos = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('🎬 Video: ${data['title']} | isLive: ${data['isLive']}');
        return VideoModel.fromFirestore(doc);
      }).toList();
      
      print('✅ Converted to ${videos.length} VideoModel objects');
      return videos;
    });
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('videos').get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null)
          .cast<String>() // Cast to non-nullable String
          .toSet()
          .toList();
      return ['All', ...categories];
    } catch (e) {
      print('Error fetching categories: $e');
      return ['All'];
    }
  }

  // Get featured/hero live stream
  Future<VideoModel?> getFeaturedLiveStream() async {
    try {
      final snapshot = await _firestore
          .collection('videos')
          .where('isLive', isEqualTo: true)
          .where('featured', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return VideoModel.fromFirestore(snapshot.docs.first);
      }

      // If no featured, return first live stream
      final fallbackSnapshot = await _firestore
          .collection('videos')
          .where('isLive', isEqualTo: true)
          .limit(1)
          .get();

      if (fallbackSnapshot.docs.isNotEmpty) {
        return VideoModel.fromFirestore(fallbackSnapshot.docs.first);
      }

      return null;
    } catch (e) {
      print('Error fetching featured stream: $e');
      return null;
    }
  }

  // Get viewer count for a video (if you want to track this)
  Stream<int> getViewerCount(String videoId) {
    return _firestore
        .collection('videos')
        .doc(videoId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.data()?['viewers'] ?? 0;
      }
      return 0;
    });
  }

  // Increment viewer count
  Future<void> incrementViewerCount(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'viewers': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing viewer count: $e');
    }
  }

  // Test Firestore connection - FOR DEBUGGING
  Future<void> testConnection() async {
    try {
      print('🔍 Testing Firestore connection...');
      
      // Get ALL documents
      final allSnapshot = await _firestore.collection('videos').get();
      print('✅ Total documents in collection: ${allSnapshot.docs.length}');
      
      // Show ALL documents
      for (var doc in allSnapshot.docs) {
        final data = doc.data();
        print('📄 Document ID: ${doc.id}');
        print('   - title: ${data['title']}');
        print('   - isLive: ${data['isLive']} (type: ${data['isLive'].runtimeType})');
        print('   - category: ${data['category']}');
        print('---');
      }
      
      // Count live vs archive
      final liveCount = allSnapshot.docs.where((doc) => doc.data()['isLive'] == true).length;
      final archiveCount = allSnapshot.docs.where((doc) => doc.data()['isLive'] == false).length;
      print('📊 Summary:');
      print('   🔴 Live channels: $liveCount');
      print('   📚 Archive videos: $archiveCount');
      
    } catch (e) {
      print('❌ ERROR: $e');
      print('---');
      print('Possible causes:');
      print('1. Firestore rules blocking access');
      print('2. Collection "videos" does not exist');
      print('3. No internet connection');
      print('4. Firebase not initialized properly');
    }
  }
}
