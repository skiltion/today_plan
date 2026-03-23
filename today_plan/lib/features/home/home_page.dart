import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';
import '../plan/plan_create_page.dart';
import '../record/record_create_page.dart';
import '../analysis/analysis_page.dart';
import '../history/history_page.dart';
import '../edit/edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService firebaseService = FirebaseService();

  List<Plan> plans = [];
  List<Plan> records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await firebaseService.getPlans();
    final r = await firebaseService.getRecords();

    setState(() {
      plans = p;
      records = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘 계획"),
      ),

      /// 🔥 Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text("메뉴", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              title: const Text("홈"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("기록 조회"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// 📌 계획
            const Text(
              "📌 오늘 계획",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...plans.map((plan) => Card(
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: Text(
                        "${plan.startTime.hour}:${plan.startTime.minute} ~ ${plan.endTime.hour}:${plan.endTime.minute}"),

                    /// 🔥 클릭 → 수정 페이지
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPage(
                            item: plan,
                            onSave: (updated) async {
                              await firebaseService.updatePlan(updated);
                              _loadData();
                            },
                            onDelete: () async {
                              await firebaseService.deletePlan(plan.id!);
                              _loadData();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlanCreatePage(),
                  ),
                );
                _loadData();
              },
              child: const Text("계획 추가"),
            ),

            const Divider(height: 40),

            /// 📝 기록
            const Text(
              "📝 오늘 기록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...records.map((record) => Card(
                  child: ListTile(
                    title: Text(record.title),
                    subtitle: Text(
                        "${record.startTime.hour}:${record.startTime.minute} ~ ${record.endTime.hour}:${record.endTime.minute}"),

                    /// 🔥 클릭 → 수정 페이지
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPage(
                            item: record,
                            onSave: (updated) async {
                              await firebaseService.updateRecord(updated);
                              _loadData();
                            },
                            onDelete: () async {
                              await firebaseService.deleteRecord(record.id!);
                              _loadData();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordCreatePage(plans: plans),
                  ),
                );
                _loadData();
              },
              child: const Text("기록 추가"),
            ),

            const SizedBox(height: 30),

            /// 📊 분석 버튼
            ElevatedButton(
              onPressed: () {
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
              child: const Text("오늘 분석 보기"),
            ),
          ],
        ),
      ),
    );
  }
}