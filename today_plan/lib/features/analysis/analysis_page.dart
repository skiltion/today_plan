import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../core/utils/time_utils.dart';

class AnalysisPage extends StatelessWidget {
  final List<Plan> plans;
  final List<Plan> records;

  const AnalysisPage({
    super.key,
    required this.plans,
    required this.records,
  });

  Duration _getTotalPlannedTime() {
    return plans.fold(
      Duration.zero,
      (sum, plan) => sum + plan.endTime.difference(plan.startTime),
    );
  }

  Duration _getTotalRecordTime() {
    return records.fold(
      Duration.zero,
      (sum, record) => sum + record.endTime.difference(record.startTime),
    );
  }

  Duration _getTotalOverlapTime() {
    Duration total = Duration.zero;

    for (var plan in plans) {
      for (var record in records) {
        total += calculateOverlap(
          plan.startTime,
          plan.endTime,
          record.startTime,
          record.endTime,
        );
      }
    }

    return total;
  }

  double _getAchievementRate() {
    final planned = _getTotalPlannedTime().inMinutes;
    final overlap = _getTotalOverlapTime().inMinutes;

    if (planned == 0) return 0;

    return (overlap / planned) * 100;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return "$hours시간 $minutes분";
  }

  Color _getColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.blue;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final plannedTime = _getTotalPlannedTime();
    final recordTime = _getTotalRecordTime();
    final overlapTime = _getTotalOverlapTime();
    final rate = _getAchievementRate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("분석 결과"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 달성률
            Text(
              "${rate.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getColor(rate),
              ),
            ),

            const Text("달성률"),

            const SizedBox(height: 30),

            Divider(),

            const SizedBox(height: 10),

            // 📊 상세 정보
            _buildRow("계획 시간", _formatDuration(plannedTime)),
            _buildRow("실제 시간", _formatDuration(recordTime)),
            _buildRow("겹친 시간", _formatDuration(overlapTime)),

            const SizedBox(height: 30),

            Divider(),

            const SizedBox(height: 20),

            // 💡 피드백
            Text(
              _getFeedback(rate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }

  String _getFeedback(double rate) {
    if (rate >= 80) return "🔥 계획을 매우 잘 지켰어요!";
    if (rate >= 50) return "👍 나쁘지 않아요. 조금만 더!";
    return "⚠️ 계획 대비 실천이 부족해요.";
  }
}