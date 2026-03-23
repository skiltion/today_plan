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

  /// 🔥 시간 겹치는 부분 계산
  Duration calculateOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    final start = start1.isAfter(start2) ? start1 : start2;
    final end = end1.isBefore(end2) ? end1 : end2;

    if (start.isAfter(end)) return Duration.zero;
    return end.difference(start);
  }

  /// 🔥 계획별 달성률 계산
  Map<String, double> getAchievementByPlan() {
    Map<String, Duration> planTotal = {};
    Map<String, Duration> actualTotal = {};

    // 계획 총 시간
    for (var plan in plans) {
      final duration = plan.endTime.difference(plan.startTime);

      planTotal[plan.title] =
          (planTotal[plan.title] ?? Duration.zero) + duration;
    }

    // 실제 수행 시간 (겹치는 시간만)
    for (var record in records) {
      for (var plan in plans) {
        if (plan.title != record.title) continue;

        final overlap = calculateOverlap(
          plan.startTime,
          plan.endTime,
          record.startTime,
          record.endTime,
        );

        actualTotal[plan.title] =
            (actualTotal[plan.title] ?? Duration.zero) + overlap;
      }
    }

    // 퍼센트 계산
    Map<String, double> result = {};

    for (var title in planTotal.keys) {
      final planTime = planTotal[title]!.inMinutes;
      final actualTime = actualTotal[title]?.inMinutes ?? 0;

      double percent = (actualTime / planTime) * 100;

      // 🔥 0~100% 제한 (원하면 제거 가능)
      percent = percent.clamp(0, 100);

      result[title] = percent;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final achievementMap = getAchievementByPlan();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${date.year}-${date.month}-${date.day} 분석 결과",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: achievementMap.isEmpty
            ? const Center(
                child: Text("데이터가 없습니다"),
              )
            : ListView(
                children: achievementMap.entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔥 제목 + 퍼센트
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${entry.value.toStringAsFixed(1)}%",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// 🔥 ProgressBar
                          LinearProgressIndicator(
                            value: entry.value / 100,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}