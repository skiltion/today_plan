import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/plan_model.dart';
import '../../data/models/record_model.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/timer_state.dart';
import '../../core/background_timer_service.dart';

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

  late StreamSubscription<Map<String, dynamic>?> _serviceSub;

  @override
  void initState() {
    super.initState();

    // 백그라운드 서비스 이벤트 구독 (UI 안전하게)
    _serviceSub = FlutterBackgroundService().on("update").listen((event) {
      if (!mounted) return;
      if (event == null) return;

      final seconds = event['seconds'] ?? 0;
      context.read<TimerState>().updateFromBackground(seconds);
    });

    // 이전 선택 복원
    _restoreSelectedTitle();
  }

  @override
  void dispose() {
    _serviceSub.cancel();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _restoreSelectedTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTitle = prefs.getString("selected_plan");
    if (storedTitle != null) {
      setState(() {
        _selectedTitle = storedTitle;
      });
    }
  }

  void _onPlanChanged(String? title) async {
    setState(() {
      _selectedTitle = title;
    });
    final prefs = await SharedPreferences.getInstance();
    if (title != null) {
      await prefs.setString("selected_plan", title);
    }
  }

  // ================= 타이머 =================
  void _start() {
    final title = _useCustom ? _titleController.text : _selectedTitle;
    if (title == null || title.isEmpty) return;

    context.read<TimerState>().start(title);
    BackgroundTimerService.start(title);
  }

  void _pause() {
    context.read<TimerState>().pause();
    BackgroundTimerService.pause();
  }

  void _resume() {
    context.read<TimerState>().resume();
    BackgroundTimerService.resume();
  }

  // ================= 저장 =================
  Future<void> _saveRecord() async {
    final timer = context.read<TimerState>();
    final title = _useCustom ? _titleController.text : _selectedTitle;
    if (title == null || title.isEmpty) return;

    final recordData = timer.buildRecord();
    if (recordData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("기록 없음")));
      return;
    }

    try {
      await _firebaseService.addRecord(
        Record(
          id: '',
          title: title,
          startTime: recordData['start']!,
          endTime: recordData['end']!,
        ),
      );

      timer.reset();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("저장 완료")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("에러: $e")));
    }
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
            // 계획 선택
            if (!_useCustom)
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                hint: const Text("계획 선택"),
                items: planTitles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: _onPlanChanged,
              )
            else
              TextField(controller: _titleController),

            const SizedBox(height: 30),

            // 타이머
            Text(_format(timer.elapsed),
                style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 20),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!timer.isRunning && !timer.hasStartedOnce)
                  ElevatedButton(onPressed: _start, child: const Text("시작")),
                if (timer.isRunning)
                  ElevatedButton(onPressed: _pause, child: const Text("일시정지")),
                if (!timer.isRunning && timer.hasStartedOnce)
                  ElevatedButton(onPressed: _resume, child: const Text("재시작")),
              ],
            ),

            const SizedBox(height: 20),

            // 저장
            ElevatedButton(onPressed: _saveRecord, child: const Text("저장")),
          ],
        ),
      ),
    );
  }
}