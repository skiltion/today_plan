import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';

class AnalysisPage extends StatelessWidget {
  final List<Plan> plans;
  final List<Plan> records;
  final DateTime date;

  const AnalysisPage({
    super.key,
    required this.plans,
    required this.records,
    required this.date,
  });

  // 🔥 겹친 시간 계산 (분 단위)
  int calculateOverlapMinutes(Plan p, Plan r) {
    final start = p.startTime.isAfter(r.startTime)
        ? p.startTime
        : r.startTime;

    final end =
        p.endTime.isBefore(r.endTime) ? p.endTime : r.endTime;

    if (end.isBefore(start)) return 0;

    return end.difference(start).inMinutes;
  }

  // 🔥 계획별 분석
  Map<String, dynamic> analyzePlan(Plan plan) {
    final relatedRecords =
        records.where((r) => r.title == plan.title);

    int totalActual = 0;

    for (var r in relatedRecords) {
      totalActual += calculateOverlapMinutes(plan, r);
    }

    final planned =
        plan.endTime.difference(plan.startTime).inMinutes;

    double ratio = planned == 0 ? 0 : totalActual / planned;

    int diff = totalActual - planned; // + 초과 / - 부족

    Color color;
    if (ratio >= 0.8) {
      color = Colors.green;
    } else if (ratio >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return {
      "planned": planned,
      "actual": totalActual,
      "ratio": ratio,
      "diff": diff,
      "color": color,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totalPlans = plans.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${date.year}-${date.month}-${date.day} 분석"),
      ),
      body: plans.isEmpty
          ? const Center(child: Text("계획 없음"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                ...plans.map((plan) {
                  final result = analyzePlan(plan);

                  final planned = result["planned"];
                  final actual = result["actual"];
                  final ratio = result["ratio"];
                  final diff = result["diff"];
                  final color = result["color"];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          // 🔥 Progress Bar
                          LinearProgressIndicator(
                            value: ratio.clamp(0, 1),
                            color: color,
                            minHeight: 8,
                          ),

                          const SizedBox(height: 8),

                          Text("계획: ${planned}분"),
                          Text("실제: ${actual}분"),

                          const SizedBox(height: 4),

                          // 🔥 초과/부족 표시
                          Text(
                            diff >= 0
                                ? "🔵 ${diff}분 초과"
                                : "🔴 ${-diff}분 부족",
                            style: TextStyle(
                              color: diff >= 0
                                  ? Colors.blue
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                              "달성률: ${(ratio * 100).toStringAsFixed(1)}%"),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}