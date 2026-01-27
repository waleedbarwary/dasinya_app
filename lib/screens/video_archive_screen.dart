import 'package:flutter/material.dart';
import 'video_player_screen.dart';
import '../models/video_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';

class VideoArchiveScreen extends StatefulWidget {
  const VideoArchiveScreen({Key? key}) : super(key: key);

  @override
  State<VideoArchiveScreen> createState() => _VideoArchiveScreenState();
}

class _VideoArchiveScreenState extends State<VideoArchiveScreen> {
  String _selectedCategory = 'All';

  // Sample data - Replace with your API calls
  final List<Category> _categories = [
    Category(id: '0', name: 'All', thumbnail: '', videoCount: 45),
    Category(id: '1', name: 'News', thumbnail: '', videoCount: 12),
    Category(id: '2', name: 'Sports', thumbnail: '', videoCount: 8),
    Category(id: '3', name: 'Entertainment', thumbnail: '', videoCount: 15),
    Category(id: '4', name: 'Documentaries', thumbnail: '', videoCount: 10),
  ];

  final List<VideoModel> _sampleVideos = [
    VideoModel(
      id: '1',
      title: 'Breaking News: Latest Updates',
      description: 'Stay informed with the latest news coverage',
      thumbnailUrl: 'https://via.placeholder.com/300x200',
      videoUrl: 'https://your-server.com/videos/video1.m3u8',
      category: 'News',
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      duration: '15:30',
    ),
    VideoModel(
      id: '2',
      title: 'Sports Highlights',
      description: 'Best moments from today\'s games',
      thumbnailUrl: 'https://via.placeholder.com/300x200',
      videoUrl: 'https://your-server.com/videos/video2.m3u8',
      category: 'Sports',
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      duration: '22:45',
    ),
    VideoModel(
      id: '3',
      title: 'Entertainment Tonight',
      description: 'Celebrity interviews and entertainment news',
      thumbnailUrl: 'https://via.placeholder.com/300x200',
      videoUrl: 'https://your-server.com/videos/video3.m3u8',
      category: 'Entertainment',
      uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      duration: '30:00',
    ),
  ];

  List<VideoModel> get _filteredVideos {
    if (_selectedCategory == 'All') return _sampleVideos;
    return _sampleVideos
        .where((video) => video.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Archive'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category.name;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            )
                          : null,
                      color: isSelected ? null : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Video Grid
          Expanded(
            child: _filteredVideos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 80,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No videos found',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredVideos.length,
                    itemBuilder: (context, index) {
                      final video = _filteredVideos[index];
                      return VideoCard(
                        video: video,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl: video.videoUrl,
                                videoTitle: video.title,
                                isLive: false,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

