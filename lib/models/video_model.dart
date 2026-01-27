class VideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String category;
  final DateTime uploadDate;
  final String duration;
  final bool isLive;
  final bool featured;
  final int viewers;
  final String? logoUrl;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.category,
    required this.uploadDate,
    required this.duration,
    this.isLive = false,
    this.featured = false,
    this.viewers = 0,
    this.logoUrl,
  });

  // Factory constructor for Supabase JSON response
  factory VideoModel.fromMap(Map<String, dynamic> data) {
    return VideoModel(
      // Supabase returns id as an integer or string
      id: data['id']?.toString() ?? '',
      
      title: data['title'] ?? 'Bê Nav',
      
      description: data['description'] ?? '',
      
      // Support multiple field names for backward compatibility
      thumbnailUrl: data['thumbnail_url'] ?? data['thumbnailUrl'] ?? '',
      
      // Support multiple field names for video URL
      videoUrl: data['url'] ?? data['video_url'] ?? data['videoUrl'] ?? '',
      
      category: data['category'] ?? 'General',
      
      // Parse ISO8601 date string from Supabase
      uploadDate: data['upload_date'] != null
          ? DateTime.parse(data['upload_date'])
          : (data['created_at'] != null 
              ? DateTime.parse(data['created_at'])
              : DateTime.now()),
          
      duration: data['duration'] ?? '00:00',
      
      isLive: data['is_live'] ?? data['isLive'] ?? false,
      
      featured: data['featured'] ?? false,
      
      viewers: data['viewers'] ?? 0,
      
      logoUrl: data['logo_url'] ?? data['logoUrl'],
    );
  }

  // Convert to Supabase-compatible Map for insert/update
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'url': videoUrl,
      'category': category,
      'upload_date': uploadDate.toIso8601String(),
      'duration': duration,
      'is_live': isLive,
      'featured': featured,
      'viewers': viewers,
      'logo_url': logoUrl,
    };
  }
}
