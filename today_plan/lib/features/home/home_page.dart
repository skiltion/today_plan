import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../data/services/timer_state.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/record_model.dart';

import '../plan/plan_create_page.dart';
import '../record/record_create_page.dart';
import '../analysis/analysis_page.dart';
import '../calendar/calendar_page.dart';
import '../plan/plan_edit_page.dart';
import '../record/record_edit_page.dart';

import '../auth/login_page.dart';
import '../../core/background_timer_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Stream<List<Plan>> getPlansStream() {
    if (userId == null) return const Stream.empty();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return FirebaseFirestore.instance
        .collection('plans')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: today)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Plan.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<Record>> getRecordsStream() {
    if (userId == null) return const Stream.empty();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Record.fromMap(doc.id, doc.data())).toList());
  }

  double calculateAchievement(List<Plan> plans, List<Record> records) {
    if (plans.isEmpty) return 0;
    double totalPlanned = 0;
    double totalActual = 0;

    for (var plan in plans) {
      totalPlanned += plan.duration;
      final related = records.where((r) => r.title == plan.title);
      for (var r in related) {
        totalActual += r.endTime.difference(r.startTime).inMinutes;
      }
    }

    if (totalPlanned == 0) return 0;
    return (totalActual / totalPlanned).clamp(0, 1);
  }

  Color getColor(double ratio) {
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String formatTime(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String formatDuration(Duration d) =>
      "${d.inHours}h ${(d.inMinutes % 60)}m";

  Future<void> _onLogout() async {
    // 타이머 중지
    BackgroundTimerService.stop();

    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 로그인 페이지 이동
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _onSave() async {
    // 타이머 초기화
    BackgroundTimerService.stop();

    setState(() {
      // UI 상태 초기화 필요 시 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("하루계획"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: timer.isRunning
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "⏱ ${timer.currentTitle} (${timer.elapsed.inSeconds}s)",
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              : const SizedBox(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("메뉴")),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("캘린더"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("로그아웃"),
              onTap: _onLogout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Plan>>(
        stream: getPlansStream(),
        builder: (context, planSnap) {
          if (!planSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plans = planSnap.data!;
          return StreamBuilder<List<Record>>(
            stream: getRecordsStream(),
            builder: (context, recordSnap) {
              if (!recordSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final records = recordSnap.data!;
              final ratio = calculateAchievement(plans, records);
              final color = getColor(ratio);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 오늘 달성률
                    GestureDetector(
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
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text("오늘 달성률"),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProgressIndicator(
                                value: ratio,
                                strokeWidth: 10,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${(ratio * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 리스트
                    Expanded(
                      child: ListView(
                        children: [
                          const Text("📌 계획", style: TextStyle(fontSize: 18)),
                          if (plans.isEmpty) const Text("계획 없음"),
                          ...plans.map((p) => ListTile(
                                title: Text(p.title),
                                subtitle: Text("${p.duration}분"),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlanEditPage(plan: p),
                                    ),
                                  );
                                  if (result == null) return;
                                  if (result is Map && result["delete"] == true) {
                                    await FirebaseFirestore.instance
                                        .collection('plans')
                                        .doc(result["id"])
                                        .delete();
                                  }
                                },
                              )),
                          const Divider(),
                          const Text("📝 기록", style: TextStyle(fontSize: 18)),
                          if (records.isEmpty) const Text("기록 없음"),
                          ...records.map((r) => ListTile(
                                title: Text(r.title),
                                subtitle: Text(
                                    "${formatTime(r.startTime)} ~ ${formatTime(r.endTime)}"),
                                trailing: Text(formatDuration(
                                    r.endTime.difference(r.startTime))),
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
                MaterialPageRoute(builder: (_) => const PlanCreatePage()),
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
                  builder: (_) => RecordCreatePage(plans: plans),
                ),
              );
            },
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}