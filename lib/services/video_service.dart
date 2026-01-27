import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_category.dart';
import '../models/video_item.dart';

class VideoService {
  // Replace with your actual API base URL
  static const String baseUrl = 'https://your-server.com/api';
  
  // Your live stream URL
  static const String liveStreamUrl = 'https://your-server.com/live/stream.m3u8';

  // Fetch video categories
  Future<List<VideoCategory>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // For demo purposes, return dummy data
      return _getDummyCategories();
    }
  }

  // Fetch videos by category
  Future<List<VideoItem>> fetchVideosByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos?category_id=$categoryId')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      // For demo purposes, return dummy data
      return _getDummyVideos(categoryId);
    }
  }

  // Dummy data for testing
  List<VideoCategory> _getDummyCategories() {
    return [
      VideoCategory(
        id: '1',
        name: 'News',
        thumbnail: 'https://via.placeholder.com/300x200?text=News',
        videoCount: 25,
      ),
      VideoCategory(
        id: '2',
        name: 'Sports',
        thumbnail: 'https://via.placeholder.com/300x200?text=Sports',
        videoCount: 18,
      ),
      VideoCategory(
        id: '3',
        name: 'Entertainment',
        thumbnail: 'https://via.placeholder.com/300x200?text=Entertainment',
        videoCount: 32,
      ),
      VideoCategory(
        id: '4',
        name: 'Documentaries',
        thumbnail: 'https://via.placeholder.com/300x200?text=Documentaries',
        videoCount: 15,
      ),
    ];
  }

  List<VideoItem> _getDummyVideos(String categoryId) {
    return [
      VideoItem(
        id: '1',
        title: 'Sample Video 1',
        description: 'This is a sample video description',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnail: 'https://via.placeholder.com/400x225?text=Video+1',
        duration: '10:25',
        categoryId: categoryId,
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VideoItem(
        id: '2',
        title: 'Sample Video 2',
        description: 'Another sample video description',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnail: 'https://via.placeholder.com/400x225?text=Video+2',
        duration: '15:30',
        categoryId: categoryId,
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}

