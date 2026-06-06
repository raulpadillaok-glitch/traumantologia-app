class Session {
  final String id;
  final String userId;
  final String exerciseId;
  final DateTime date;
  final double maxAngle;
  final List<double> anglesHistory;

  Session({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    required this.maxAngle,
    this.anglesHistory = const [],
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      userId: json['userId'] ?? 'default_user', // Fallback for old data
      exerciseId: json['exerciseId'],
      date: DateTime.parse(json['date']),
      maxAngle: json['maxAngle'].toDouble(),
      anglesHistory: json['anglesHistory'] != null 
          ? List<double>.from(json['anglesHistory'].map((x) => x.toDouble())) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'maxAngle': maxAngle,
      'anglesHistory': anglesHistory,
    };
  }
}
