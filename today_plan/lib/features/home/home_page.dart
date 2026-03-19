import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../widgets/plan_card.dart';
import '../plan/plan_create_page.dart';
import '../record/record_create_page.dart';
import '../analysis/analysis_page.dart';
import '../../data/services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _service = FirebaseService();

  List<Plan> plans = [];
  List<Plan> records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedPlans = await _service.getPlans();
    final loadedRecords = await _service.getRecords();

    setState(() {
      plans = loadedPlans;
      records = loadedRecords;
    });
  }

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("하루계획"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData, // 🔥 당겨서 새로고침
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📅 날짜
              Text(
                getTodayDate(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 📋 오늘 계획
              const Text(
                "📋 오늘 계획",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (plans.isEmpty)
                const Text("계획이 없습니다")
              else
                ...plans.map((plan) => PlanCard(plan: plan)),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  final newPlan = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlanCreatePage(),
                    ),
                  );

                  if (newPlan != null) {
                    await _service.addPlan(newPlan); // 🔥 DB 저장
                    _loadData(); // 🔥 다시 불러오기
                  }
                },
                child: const Text("+ 계획 추가"),
              ),

              const SizedBox(height: 30),

              // 📝 실제 기록
              const Text(
                "📝 실제 기록",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (records.isEmpty)
                const Text("기록이 없습니다")
              else
                ...records.map((record) => PlanCard(plan: record)),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  final newRecord = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecordCreatePage(),
                    ),
                  );

                  if (newRecord != null) {
                    await _service.addRecord(newRecord); // 🔥 DB 저장
                    _loadData();
                  }
                },
                child: const Text("+ 기록 추가"),
              ),

              const SizedBox(height: 40),

              // 📊 분석 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisPage(
                          plans: plans,
                          records: records,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "비교 분석하기",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}