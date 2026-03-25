import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  Map<String, double> getAchievementByPlan() {
    Map<String, Duration> planTotal = {};
    Map<String, Duration> actualTotal = {};

    for (var plan in plans) {
      final duration = plan.endTime.difference(plan.startTime);
      planTotal[plan.title] =
          (planTotal[plan.title] ?? Duration.zero) + duration;
    }

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

    Map<String, double> result = {};

    for (var title in planTotal.keys) {
      final planTime = planTotal[title]!.inMinutes;
      final actualTime = actualTotal[title]?.inMinutes ?? 0;

      result[title] = ((actualTime / planTime) * 100).clamp(0, 100);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final data = getAchievementByPlan();
    final entries = data.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${date.year}.${date.month}.${date.day} 분석",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: entries.isEmpty
            ? const Center(child: Text("데이터 없음"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 그래프 카드
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= entries.length) {
                                      return const SizedBox();
                                    }
                                    return Text(
                                      entries[value.toInt()].key,
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(entries.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: entries[i].value,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 리스트 + ProgressBar
                  Expanded(
                    child: ListView(
                      children: entries.map((e) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 제목 + 퍼센트
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${e.value.toStringAsFixed(1)}%",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                /// ProgressBar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: e.value / 100,
                                    minHeight: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}