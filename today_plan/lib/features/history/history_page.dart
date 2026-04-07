import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseService firebaseService = FirebaseService();

  DateTime selectedDate = DateTime.now();

  List<Plan> plans = [];
  List<Plan> records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p = await firebaseService.getPlansByDate(selectedDate);
    final r = await firebaseService.getRecordsByDate(selectedDate);

    setState(() {
      plans = p;
      records = r;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;
      _loadData();
    }
  }

  int getDiff(Plan plan, Plan record) {
    final planMin =
        plan.endTime.difference(plan.startTime).inMinutes;
    final recordMin =
        record.endTime.difference(record.startTime).inMinutes;

    return recordMin - planMin;
  }

  Plan? findRecord(Plan plan) {
    try {
      return records.firstWhere((r) => r.title == plan.title);
    } catch (e) {
      return null;
    }
  }

  Color getColor(int diff) {
    if (diff == 0) return Colors.blue;
    if (diff > 0) return Colors.red;
    return Colors.green;
  }

  String formatDiff(int diff) {
    if (diff == 0) return "정확";
    if (diff > 0) return "$diff분 초과";
    return "${diff.abs()}분 부족";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: plans.isEmpty && records.isEmpty
          ? const Center(child: Text("기록 없음"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: plans.map((plan) {
                final record = findRecord(plan);

                int diff = 0;
                if (record != null) {
                  diff = getDiff(plan, record);
                }

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: record == null
                        ? const Text("기록 없음")
                        : Text(formatDiff(diff)),
                    trailing: record == null
                        ? const Icon(Icons.error, color: Colors.grey)
                        : Icon(Icons.circle, color: getColor(diff)),
                  ),
                );
              }).toList(),
            ),
    );
  }
}