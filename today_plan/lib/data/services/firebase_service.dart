import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 계획 저장
  Future<void> addPlan(Plan plan) async {
    await _db.collection('plans').add({
      'title': plan.title,
      'startTime': plan.startTime,
      'endTime': plan.endTime,
      'date': DateTime.now(),
    });
  }

  // 🔥 계획 불러오기
  Future<List<Plan>> getPlans() async {
    final snapshot = await _db.collection('plans').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Plan(
        id: doc.id,
        title: data['title'],
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
      );
    }).toList();
  }

  // 🔥 기록 저장
  Future<void> addRecord(Plan record) async {
    await _db.collection('records').add({
      'title': record.title,
      'startTime': record.startTime,
      'endTime': record.endTime,
      'date': DateTime.now(),
    });
  }

  // 🔥 기록 불러오기
  Future<List<Plan>> getRecords() async {
    final snapshot = await _db.collection('records').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Plan(
        id: doc.id,
        title: data['title'],
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
      );
    }).toList();
  }
}