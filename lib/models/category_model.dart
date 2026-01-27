class Category {
  final String id;
  final String name;
  final String thumbnail;
  final int videoCount;

  Category({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.videoCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoCount: json['video_count'] ?? 0,
    );
  }
}

