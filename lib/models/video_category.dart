class VideoCategory {
  final String id;
  final String name;
  final String thumbnail;
  final int videoCount;

  VideoCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.videoCount,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoCount: json['video_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'video_count': videoCount,
    };
  }
}

