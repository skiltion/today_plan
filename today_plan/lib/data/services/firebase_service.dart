import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plan_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPlan(Plan plan) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('plans').add({
      'userId': user!.uid,
      'title': plan.title,
      'startTime': plan.startTime,
      'endTime': plan.endTime,
      'date': DateTime.now().toIso8601String().substring(0, 10), // 🔥 추가
    });
  }

  Future<List<Plan>> getPlans() async {
    final user = FirebaseAuth.instance.currentUser;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('plans')
        .where('userId', isEqualTo: user!.uid)
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .get();

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

  Future<void> addRecord(Plan record) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('records').add({
      'userId': user!.uid,
      'title': record.title,
      'startTime': record.startTime,
      'endTime': record.endTime,
    });
  }

  Future<List<Plan>> getRecords() async {
    final user = FirebaseAuth.instance.currentUser;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('records')
        .where('userId', isEqualTo: user!.uid)
        .where('startTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startTime', isLessThan: endOfDay)
        .get();

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

  Future<void> deletePlan(String id) async {
    await _db.collection('plans').doc(id).delete();
  }

  Future<void> deleteRecord(String id) async {
    await _db.collection('records').doc(id).delete();
  }

  Future<List<Plan>> getPlansByDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('plans')
        .where('userId', isEqualTo: user!.uid)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .get();

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

  Future<List<Plan>> getRecordsByDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('records')
        .where('userId', isEqualTo: user!.uid)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .get();

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

  Future<void> updatePlan(Plan plan) async {
    await _db.collection('plans').doc(plan.id).update({
      'title': plan.title,
      'startTime': plan.startTime,
      'endTime': plan.endTime,
    });
  }

  Future<void> updateRecord(Plan record) async {
    await _db.collection('records').doc(record.id).update({
      'title': record.title,
      'startTime': record.startTime,
      'endTime': record.endTime,
    });
  }
}