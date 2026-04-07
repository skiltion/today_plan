import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';

class PlanEditPage extends StatefulWidget {
  final Plan plan;

  const PlanEditPage({super.key, required this.plan});

  @override
  State<PlanEditPage> createState() => _PlanEditPageState();
}

class _PlanEditPageState extends State<PlanEditPage> {
  late TextEditingController _titleController;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.plan.title);

    _startTime = TimeOfDay.fromDateTime(widget.plan.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.plan.endTime);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
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
      id: widget.plan.id,
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

    Navigator.pop(context, updated);
  }

  void _delete() {
    Navigator.pop(context, {"delete": true, "id": widget.plan.id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("계획 수정")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("시작"),
                TextButton(
                  onPressed: () => _pickTime(true),
                  child: Text(_startTime!.format(context)),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("종료"),
                TextButton(
                  onPressed: () => _pickTime(false),
                  child: Text(_endTime!.format(context)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _save, child: const Text("수정")),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _delete,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red),
              child: const Text("삭제"),
            ),
          ],
        ),
      ),
    );
  }
}