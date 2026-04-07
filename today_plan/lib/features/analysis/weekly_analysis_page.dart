import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/plan_model.dart';

class WeeklyAnalysisPage extends StatefulWidget {
  const WeeklyAnalysisPage({super.key});

  @override
  State<WeeklyAnalysisPage> createState() => _WeeklyAnalysisPageState();
}

class _WeeklyAnalysisPageState extends State<WeeklyAnalysisPage> {
  final FirebaseService firebaseService = FirebaseService();

  List<double> weeklyRates = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    List<double> temp = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));

      final plans = await firebaseService.getPlansByDate(date);
      final records = await firebaseService.getRecordsByDate(date);

      temp.add(_calculate(plans, records));
    }

    setState(() {
      weeklyRates = temp;
    });
  }

  double _calculate(List<Plan> plans, List<Plan> records) {
    if (plans.isEmpty) return 0;

    int success = 0;

    for (var p in plans) {
      if (records.any((r) => r.title == p.title)) {
        success++;
      }
    }

    return success / plans.length;
  }

  List<BarChartGroupData> _buildBars() {
    return List.generate(7, (index) {
      final value = weeklyRates[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value * 100,
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: value > 0.7
                  ? [Colors.green, Colors.lightGreen]
                  : value > 0.4
                      ? [Colors.orange, Colors.amber]
                      : [Colors.red, Colors.redAccent],
            ),
            width: 18,
          )
        ],
      );
    });
  }

  String _dayLabel(int index) {
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    return "${date.month}/${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final avg =
        weeklyRates.reduce((a, b) => a + b) / weeklyRates.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("주간 통계"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 평균 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("주간 평균 달성률"),
                  const SizedBox(height: 10),
                  Text(
                    "${(avg * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 그래프 카드
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            return Text(_dayLabel(value.toInt()));
                          },
                        ),
                      ),
                    ),
                    barGroups: _buildBars(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}