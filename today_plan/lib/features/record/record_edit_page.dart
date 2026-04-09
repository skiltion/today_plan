import 'package:flutter/material.dart';
import '../../data/models/record_model.dart';

class RecordEditPage extends StatelessWidget {
  final Record record;

  const RecordEditPage({super.key, required this.record});

  void _delete(BuildContext context) {
    Navigator.pop(context, {"delete": true, "id": record.id});
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:"
        "${t.minute.toString().padLeft(2, '0')}:"
        "${t.second.toString().padLeft(2, '0')}";
  }

  String _formatDuration(Duration d) {
    return "${d.inHours}시간 "
        "${d.inMinutes % 60}분 "
        "${d.inSeconds % 60}초";
  }

  @override
  Widget build(BuildContext context) {
    final duration = record.endTime.difference(record.startTime);

    return Scaffold(
      appBar: AppBar(title: const Text("기록 상세")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 제목
            ListTile(
              title: const Text("제목"),
              subtitle: Text(record.title),
            ),

            const Divider(),

            // 시간
            ListTile(
              title: const Text("시간"),
              subtitle: Text(
                "${_formatTime(record.startTime)} ~ ${_formatTime(record.endTime)}",
              ),
            ),

            // 총 시간
            ListTile(
              title: const Text("총 수행 시간"),
              subtitle: Text(_formatDuration(duration)),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _delete(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("삭제"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}