import 'package:flutter/material.dart';
import '../data/models/plan_model.dart'; // Plan은 그대로 import
import '../data/models/record_model.dart'; // 🔥 Record 따로 사용

class RecordCard extends StatelessWidget {
  final Record record;

  const RecordCard({super.key, required this.record});

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;

    if (hours == 0) return "${minutes}분";
    if (minutes == 0) return "${hours}시간";

    return "${hours}시간 ${minutes}분";
  }

  @override
  Widget build(BuildContext context) {
    final duration = record.endTime.difference(record.startTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 시간
            Text(
              "${_formatTime(record.startTime)} ~ ${_formatTime(record.endTime)}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 4),

            // 제목
            Text(
              record.title,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            // 🔥 총 수행 시간
            Text(
              "총 ${_formatDuration(duration)}",
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}