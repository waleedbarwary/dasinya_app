class VideoItem {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final String duration;
  final String categoryId;
  final DateTime publishedDate;

  VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.duration,
    required this.categoryId,
    required this.publishedDate,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '0:00',
      categoryId: json['category_id'] ?? '',
      publishedDate: json['published_date'] != null
          ? DateTime.parse(json['published_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'duration': duration,
      'category_id': categoryId,
      'published_date': publishedDate.toIso8601String(),
    };
  }
}

