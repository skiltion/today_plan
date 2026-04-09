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
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.plan.title);

    _durationController =
        TextEditingController(text: widget.plan.duration.toString());
  }

  void _save() {
    final duration = int.tryParse(_durationController.text);

    if (_titleController.text.isEmpty ||
        duration == null ||
        duration <= 0) {
      return;
    }

    final updated = Plan(
      id: widget.plan.id,
      title: _titleController.text,
      duration: duration,
      date: widget.plan.date,
    );

    Navigator.pop(context, updated);
  }

  void _delete() {
    Navigator.pop(context, {
      "delete": true,
      "id": widget.plan.id,
    });
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

            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "시간 (분)"),
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