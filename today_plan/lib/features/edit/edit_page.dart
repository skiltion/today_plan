import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';

class EditPage extends StatefulWidget {
  final Plan item;
  final Function(Plan) onSave;
  final Function() onDelete;

  const EditPage({
    super.key,
    required this.item,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.item.title);

    _startTime = TimeOfDay.fromDateTime(widget.item.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.item.endTime);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime! : _endTime!,
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

  void _save() {
    final now = DateTime.now();

    final updated = Plan(
      id: widget.item.id,
      title: _titleController.text,
      startTime: DateTime(
        now.year,
        now.month,
        now.day,
        _startTime!.hour,
        _startTime!.minute,
      ),
      endTime: DateTime(
        now.year,
        now.month,
        now.day,
        _endTime!.hour,
        _endTime!.minute,
      ),
    );

    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String format(TimeOfDay t) =>
        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("수정")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("시작"),
                TextButton(
                  onPressed: () => _pickTime(true),
                  child: Text(format(_startTime!)),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("종료"),
                TextButton(
                  onPressed: () => _pickTime(false),
                  child: Text(format(_endTime!)),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              child: const Text("수정 저장"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onDelete();
                Navigator.pop(context);
              },
              child: const Text("삭제"),
            ),
          ],
        ),
      ),
    );
  }
}