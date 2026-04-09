import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/record_model.dart';

class AnalysisPage extends StatelessWidget {
  final List<Plan> plans;
  final List<Record> records;
  final DateTime date;

  const AnalysisPage({
    super.key,
    required this.plans,
    required this.records,
    required this.date,
  });

  // 🔥 실제 수행 시간 계산 (분)
  int calculateActualMinutes(String title) {
    final related =
        records.where((r) => r.title == title);

    int total = 0;

    for (var r in related) {
      total += r.endTime
          .difference(r.startTime)
          .inMinutes;
    }

    return total;
  }

  // 🔥 계획 분석
  Map<String, dynamic> analyzePlan(Plan plan) {
    final planned = plan.duration; // 🔥 핵심 변경
    final actual = calculateActualMinutes(plan.title);

    final ratio =
        planned == 0 ? 0 : (actual / planned).clamp(0, 1);

    final diff = actual - planned;

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
      "actual": actual,
      "ratio": ratio,
      "diff": diff,
      "color": color,
    };
  }

  String formatDate(DateTime d) {
    return "${d.year}-${d.month}-${d.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${formatDate(date)} 분석"),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 🔥 진행률 바
                          LinearProgressIndicator(
                            value: ratio,
                            color: color,
                            minHeight: 8,
                          ),

                          const SizedBox(height: 8),

                          Text("계획: ${planned}분"),
                          Text("실제: ${actual}분"),

                          const SizedBox(height: 4),

                          // 🔥 초과/부족
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
                            "달성률: ${(ratio * 100).toStringAsFixed(1)}%",
                          ),
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