import 'package:flutter/material.dart';
import '../../widgets/plan_card.dart';
import '../../widgets/record_card.dart';
import '../../data/models/plan_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // 🔥 임시 더미 데이터 (나중에 Firebase로 교체)
  List<Plan> getDummyPlans() {
    return [
      Plan(
        id: '1',
        title: '공부',
        startTime: DateTime(2026, 3, 18, 10, 0),
        endTime: DateTime(2026, 3, 18, 12, 0),
      ),
      Plan(
        id: '2',
        title: '운동',
        startTime: DateTime(2026, 3, 18, 14, 0),
        endTime: DateTime(2026, 3, 18, 15, 0),
      ),
    ];
  }

  List<Plan> getDummyRecords() {
    return [
      Plan(
        id: '1',
        title: '공부',
        startTime: DateTime(2026, 3, 18, 11, 0),
        endTime: DateTime(2026, 3, 18, 12, 30),
      ),
      Plan(
        id: '2',
        title: '유튜브',
        startTime: DateTime(2026, 3, 18, 15, 0),
        endTime: DateTime(2026, 3, 18, 16, 0),
      ),
    ];
  }

  String getTodayDate() {
    final now = DateTime.now();
    return "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final plans = getDummyPlans();
    final records = getDummyRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text("하루계획"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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

            // 📋 계획 섹션
            const Text(
              "📋 오늘 계획",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...plans.map((plan) => PlanCard(plan: plan)),

            const SizedBox(height: 10),

            // ➕ 계획 추가 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 계획 작성 페이지 이동
              },
              child: const Text("+ 계획 추가"),
            ),

            const SizedBox(height: 30),

            // 📝 기록 섹션
            const Text(
              "📝 실제 기록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...records.map((record) => PlanCard(plan: record)),

            const SizedBox(height: 10),

            // ➕ 기록 추가 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 기록 작성 페이지 이동
              },
              child: const Text("+ 기록 추가"),
            ),

            const SizedBox(height: 40),

            // 📊 분석 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 분석 페이지 이동
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
    );
  }
}