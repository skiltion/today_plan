import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plan_model.dart';
import '../models/record_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================== 계획 ==================

  Future<void> addPlan(Plan plan) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('plans').add(plan.toMap(user!.uid));
  }

  Future<List<Plan>> getPlans() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final snapshot = await _db
        .collection('plans')
        .where('userId', isEqualTo: user!.uid)
        .where('date', isEqualTo: today)
        .get();

    return snapshot.docs
        .map((doc) => Plan.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> updatePlan(Plan plan) async {
    await _db.collection('plans').doc(plan.id).update({
      'title': plan.title,
      'duration': plan.duration,
    });
  }

  Future<void> deletePlan(String id) async {
    await _db.collection('plans').doc(id).delete();
  }

  // ================== 기록 ==================

  Future<void> addRecord(Record record) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('records').add(record.toMap(user!.uid));
  }

  Future<List<Record>> getRecords() async {
    final user = FirebaseAuth.instance.currentUser;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('records')
        .where('userId', isEqualTo: user!.uid)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .get();

    return snapshot.docs
        .map((doc) => Record.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> deleteRecord(String id) async {
    await _db.collection('records').doc(id).delete();
  }
}