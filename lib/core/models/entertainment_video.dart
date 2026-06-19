class EntertainmentVideo {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String category;
  final String icon;

  EntertainmentVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.icon,
  });

  factory EntertainmentVideo.fromJson(Map<String, dynamic> json) {
    return EntertainmentVideo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      category: json['category']?.toString() ?? 'learn',
      icon: json['icon']?.toString() ?? 'play_circle',
    );
  }
}
