class Record {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  Record({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  // Firestore → Model
  factory Record.fromMap(String id, Map<String, dynamic> data) {
    return Record(
      id: id,
      title: data['title'] ?? '',
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
    );
  }

  // Model → Firestore
  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}