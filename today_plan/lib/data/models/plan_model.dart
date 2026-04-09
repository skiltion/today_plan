class Plan {
  final String id;
  final String title;
  final int duration; // 🔥 분 단위
  final String date;  // yyyy-MM-dd

  Plan({
    required this.id,
    required this.title,
    required this.duration,
    required this.date,
  });

  // 🔥 Firestore → Model
  factory Plan.fromMap(String id, Map<String, dynamic> data) {
    return Plan(
      id: id,
      title: data['title'] ?? '',
      duration: data['duration'] ?? 0,
      date: data['date'] ?? '',
    );
  }

  // 🔥 Model → Firestore
  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'duration': duration,
      'date': date,
    };
  }
}