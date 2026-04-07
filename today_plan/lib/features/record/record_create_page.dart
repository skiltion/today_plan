import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';

class RecordCreatePage extends StatefulWidget {
  final List<Plan> plans;

  const RecordCreatePage({
    super.key,
    required this.plans,
  });

  @override
  State<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends State<RecordCreatePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();

  String? _selectedTitle;
  bool _useCustom = false;

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _currentStart;

  bool _isRunning = false;

  List<Map<String, DateTime>> _segments = [];

  // ================== 타이머 ==================

  void _start() {
    _currentStart = DateTime.now();
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _calculateTotalDuration();
      });
    });

    setState(() {});
  }

  void _pause() {
    if (_currentStart != null) {
      _segments.add({
        'start': _currentStart!,
        'end': DateTime.now(),
      });
    }

    _timer?.cancel();
    _isRunning = false;
    _currentStart = null;

    setState(() {
      _elapsed = _calculateTotalDuration();
    });
  }

  void _resume() {
    _start();
  }

  Duration _calculateTotalDuration() {
    Duration total = Duration.zero;

    for (var s in _segments) {
      total += s['end']!.difference(s['start']!);
    }

    if (_isRunning && _currentStart != null) {
      total += DateTime.now().difference(_currentStart!);
    }

    return total;
  }

  // ================== 저장 ==================

  Future<void> _saveRecord() async {
    final title = _useCustom ? _titleController.text : _selectedTitle;

    if (title == null || title.isEmpty || _segments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("기록이 없습니다")),
      );
      return;
    }

    try {
      for (var s in _segments) {
        final record = Plan(
          id: '',
          title: title,
          startTime: s['start']!,
          endTime: s['end']!,
        );

        await _firebaseService.addRecord(record);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("기록 저장 완료")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러: $e")),
      );
    }
  }

  // ================== UI ==================

  String _formatDuration(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planTitles = widget.plans.map((p) => p.title).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: const Text("타이머 기록")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ===== 제목 선택 =====
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("계획 선택"),
                    value: false,
                    groupValue: _useCustom,
                    onChanged: (value) {
                      setState(() => _useCustom = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("직접 입력"),
                    value: true,
                    groupValue: _useCustom,
                    onChanged: (value) {
                      setState(() => _useCustom = value!);
                    },
                  ),
                ),
              ],
            ),

            if (!_useCustom)
              DropdownButtonFormField<String>(
                hint: const Text("계획 선택"),
                items: planTitles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedTitle = value);
                },
              )
            else
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "제목"),
              ),

            const SizedBox(height: 30),

            // ===== 타이머 =====
            Text(
              _formatDuration(_elapsed),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ===== 버튼 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRunning && _segments.isEmpty)
                  ElevatedButton(
                    onPressed: _start,
                    child: const Text("시작"),
                  ),

                if (_isRunning)
                  ElevatedButton(
                    onPressed: _pause,
                    child: const Text("일시정지"),
                  ),

                if (!_isRunning && _segments.isNotEmpty)
                  ElevatedButton(
                    onPressed: _resume,
                    child: const Text("재시작"),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== 기록 저장 =====
            ElevatedButton(
              onPressed: _saveRecord,
              child: const Text("기록 저장"),
            ),

            const SizedBox(height: 20),

            // ===== 세그먼트 표시 =====
            Expanded(
              child: ListView(
                children: _segments.map((s) {
                  final diff = s['end']!.difference(s['start']!);
                  return ListTile(
                    title: Text(
                        "${s['start']!.hour}:${s['start']!.minute} ~ ${s['end']!.hour}:${s['end']!.minute}"),
                    subtitle: Text("${diff.inMinutes}분"),
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