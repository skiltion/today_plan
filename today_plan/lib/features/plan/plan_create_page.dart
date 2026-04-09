import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';

class PlanCreatePage extends StatefulWidget {
  const PlanCreatePage({super.key});

  @override
  State<PlanCreatePage> createState() => _PlanCreatePageState();
}

class _PlanCreatePageState extends State<PlanCreatePage> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _firebaseService = FirebaseService();

  Future<void> _savePlan() async {
    final title = _titleController.text;
    final duration = int.tryParse(_durationController.text);

    if (title.isEmpty || duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목과 시간을 입력해주세요")),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final plan = Plan(
      id: '',
      title: title,
      duration: duration,
      date: today,
    );

    await _firebaseService.addPlan(plan);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("저장 완료")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("계획 추가")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "시간 (분)",
                hintText: "예: 120",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePlan,
                child: const Text("저장"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}