import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/plan_model.dart';
import '../plan/plan_create_page.dart';
import '../record/record_create_page.dart';
import '../analysis/analysis_page.dart';
import '../analysis/weekly_analysis_page.dart';
import '../history/history_page.dart';
import '../plan/plan_edit_page.dart';
import '../record/record_edit_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // 🔥 계획 스트림
  Stream<List<Plan>> getPlansStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Plan(
          id: doc.id,
          title: data['title'],
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // 🔥 기록 스트림
  Stream<List<Plan>> getRecordsStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Plan(
          id: doc.id,
          title: data['title'],
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // 🔥 시간 겹침 체크
  bool isOverlapping(Plan p, Plan r) {
    return p.title == r.title &&
        p.startTime.isBefore(r.endTime) &&
        p.endTime.isAfter(r.startTime);
  }

  // 🔥 달성률
  double calculateAchievement(List<Plan> plans, List<Plan> records) {
    if (plans.isEmpty) return 0;

    int success = 0;

    for (var plan in plans) {
      if (records.any((r) => isOverlapping(plan, r))) {
        success++;
      }
    }

    return success / plans.length;
  }

  String formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("하루계획"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),

      // 🔥 Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("메뉴", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("홈"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("기록 조회"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("주간 통계"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WeeklyAnalysisPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<List<Plan>>(
        stream: getPlansStream(),
        builder: (context, planSnapshot) {
          if (!planSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = planSnapshot.data!;

          return StreamBuilder<List<Plan>>(
            stream: getRecordsStream(),
            builder: (context, recordSnapshot) {
              if (!recordSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = recordSnapshot.data!;
              final achievement =
                  calculateAchievement(plans, records);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    // 🔥 원형 그래프 카드
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnalysisPage(
                                plans: plans,
                                records: records,
                                date: DateTime.now(),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            const Text("오늘 달성률",
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 140,
                                  width: 140,
                                  child: CircularProgressIndicator(
                                    value: achievement,
                                    strokeWidth: 12,
                                  ),
                                ),
                                Text(
                                  "${(achievement * 100).toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView(
                        children: [

                          const Text("📌 계획",
                              style: TextStyle(fontSize: 18)),

                          if (plans.isEmpty)
                            const Text("계획 없음"),

                          ...plans.map((p) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                      Icons.event_note,
                                      color: Colors.blue),
                                  title: Text(p.title),
                                  subtitle: Text(
                                      "${formatTime(p.startTime)} ~ ${formatTime(p.endTime)}"),
                                  onTap: () async {
                                    final result =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlanEditPage(plan: p),
                                      ),
                                    );

                                    if (result == null) return;

                                    if (result is Map &&
                                        result["delete"] == true) {
                                      await FirebaseFirestore.instance
                                          .collection('plans')
                                          .doc(result["id"])
                                          .delete();
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('plans')
                                          .doc(result.id)
                                          .update({
                                        "title": result.title,
                                        "startTime":
                                            result.startTime,
                                        "endTime":
                                            result.endTime,
                                      });
                                    }
                                  },
                                ),
                              )),

                          const Divider(),

                          const Text("📝 기록",
                              style: TextStyle(fontSize: 18)),

                          if (records.isEmpty)
                            const Text("기록 없음"),

                          ...records.map((r) => Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(r.title),
                                  subtitle: Text(
                                      "${formatTime(r.startTime)} ~ ${formatTime(r.endTime)}"),
                                  onTap: () async {
                                    final result =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecordEditPage(
                                                record: r),
                                      ),
                                    );

                                    if (result == null) return;

                                    if (result is Map &&
                                        result["delete"] == true) {
                                      await FirebaseFirestore.instance
                                          .collection('records')
                                          .doc(result["id"])
                                          .delete();
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('records')
                                          .doc(result.id)
                                          .update({
                                        "title": result.title,
                                        "startTime":
                                            result.startTime,
                                        "endTime":
                                            result.endTime,
                                      });
                                    }
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "plan",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PlanCreatePage()),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "record",
            onPressed: () async {
              final plans = await getPlansStream().first;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RecordCreatePage(plans: plans),
                ),
              );
            },
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}