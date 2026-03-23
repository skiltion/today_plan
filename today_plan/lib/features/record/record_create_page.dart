import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';

class RecordCreatePage extends StatefulWidget {
  final List<Plan> plans; // 🔥 이거 추가

  const RecordCreatePage({
    super.key,
    required this.plans, // 🔥 필수
  });

  @override
  State<RecordCreatePage> createState() => _RecordCreatePageState();
}

class _RecordCreatePageState extends State<RecordCreatePage> {
  final TextEditingController _titleController = TextEditingController();

  String? _selectedTitle;
  bool _useCustom = false;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveRecord() {
    final title = _useCustom ? _titleController.text : _selectedTitle;

    if (title == null ||
        title.isEmpty ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 값을 입력해주세요")),
      );
      return;
    }

    final now = DateTime.now();

    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final newRecord = Plan(
      id: DateTime.now().toString(),
      title: title,
      startTime: startDateTime,
      endTime: endDateTime,
    );

    Navigator.pop(context, newRecord);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "선택";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final planTitles = widget.plans.map((p) => p.title).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: const Text("기록 추가")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("계획에서 선택"),
                    value: false,
                    groupValue: _useCustom,
                    onChanged: (value) {
                      setState(() {
                        _useCustom = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("직접 입력"),
                    value: true,
                    groupValue: _useCustom,
                    onChanged: (value) {
                      setState(() {
                        _useCustom = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (!_useCustom)
              DropdownButtonFormField<String>(
                hint: const Text("계획 선택"),
                items: planTitles
                    .map((title) => DropdownMenuItem(
                          value: title,
                          child: Text(title),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTitle = value;
                  });
                },
              )
            else
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "제목",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("시작 시간"),
                TextButton(
                  onPressed: () => _pickTime(true),
                  child: Text(_formatTime(_startTime)),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("종료 시간"),
                TextButton(
                  onPressed: () => _pickTime(false),
                  child: Text(_formatTime(_endTime)),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecord,
                child: const Text("저장"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}