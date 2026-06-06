class Exercise {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final String userId;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.userId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      userId: json['userId'] ?? 'global', // fallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'videoUrl': videoUrl,
      'userId': userId,
    };
  }
}
