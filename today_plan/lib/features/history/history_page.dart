import 'package:flutter/material.dart';
import '../../data/models/plan_model.dart';
import '../../data/services/firebase_service.dart';
import '../analysis/analysis_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          const Text("📌 계획"),
          ...plans.map((p) => ListTile(title: Text(p.title))),

          const Divider(),

          const Text("📝 기록"),
          ...records.map((r) => ListTile(title: Text(r.title))),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysisPage(
                    plans: plans,
                    records: records,
                    date: selectedDate,
                  ),
                ),
              );
            },
            child: const Text("분석 보기"),
          )
        ],
      ),
    );
  }
}