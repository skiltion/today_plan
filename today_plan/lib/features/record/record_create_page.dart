import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/timer_state.dart';
import '../../core/notification_service.dart';
import 'package:provider/provider.dart';

class RecordCreatePage extends StatefulWidget {
  final List<Plan> plans;

  const RecordCreatePage({super.key, required this.plans});

  @override
  State<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends State<RecordCreatePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();

  String? _selectedTitle;
  bool _useCustom = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      context.read<TimerState>().tick();
    });
  }

  void _start() {
    final title = _useCustom ? _titleController.text : _selectedTitle;
    if (title == null || title.isEmpty) return;

    context.read<TimerState>().start(title);

    NotificationService.showRunningNotification(title);
  }

  void _pause() {
    context.read<TimerState>().pause();
    NotificationService.cancelRunningNotification();
  }

  Future<void> _saveRecord() async {
    final timer = context.read<TimerState>();
    final title = _useCustom ? _titleController.text : _selectedTitle;

    if (title == null || title.isEmpty) return;

    if (timer.isRunning) {
      _pause();
    }

    if (timer.segments.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("기록 없음")));
      return;
    }

    try {
      for (var s in timer.segments) {
        await _firebaseService.addRecord(
          Plan(
            id: '',
            title: title,
            startTime: s['start']!,
            endTime: s['end']!,
          ),
        );
      }

      timer.reset();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("저장 완료")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("에러: $e")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerState>();
    final planTitles = widget.plans.map((p) => p.title).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: const Text("타이머 기록")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 제목
            if (!_useCustom)
              DropdownButtonFormField<String>(
                hint: const Text("계획 선택"),
                items: planTitles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTitle = v),
              )
            else
              TextField(controller: _titleController),

            const SizedBox(height: 30),

            Text(_format(timer.elapsed),
                style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!timer.isRunning && timer.segments.isEmpty)
                  ElevatedButton(onPressed: _start, child: const Text("시작")),

                if (timer.isRunning)
                  ElevatedButton(onPressed: _pause, child: const Text("일시정지")),

                if (!timer.isRunning && timer.segments.isNotEmpty)
                  ElevatedButton(onPressed: _start, child: const Text("재시작")),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _saveRecord, child: const Text("저장")),
          ],
        ),
      ),
    );
  }
}