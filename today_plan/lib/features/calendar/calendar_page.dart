import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/record_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Record>> _events = {};
  List<Record> _selectedRecords = [];

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadMonthlyRecords(_focusedDay);
    _loadSelectedDayRecords(_selectedDay);
  }

  // 🔥 월별 기록 → 점 표시
  Future<void> _loadMonthlyRecords(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .get();

    Map<DateTime, List<Record>> tempEvents = {};

    for (var doc in snapshot.docs) {
      final record = Record.fromMap(doc.id, doc.data());

      final day = DateTime(
        record.startTime.year,
        record.startTime.month,
        record.startTime.day,
      );

      tempEvents.putIfAbsent(day, () => []);
      tempEvents[day]!.add(record);
    }

    setState(() {
      _events = tempEvents;
    });
  }

  // 🔥 선택 날짜 기록
  Future<void> _loadSelectedDayRecords(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThan: end)
        .get();

    setState(() {
      _selectedRecords = snapshot.docs
          .map((doc) => Record.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  List<Record> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:"
        "${t.minute.toString().padLeft(2, '0')}";
  }

  String _formatDuration(Duration d) {
    return "${d.inHours}시간 ${d.inMinutes % 60}분";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📅 기록 캘린더")),

      body: Column(
        children: [
          // 🔥 캘린더
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,

            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),

            eventLoader: _getEventsForDay,

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              _loadSelectedDayRecords(selectedDay);
            },

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadMonthlyRecords(focusedDay);
            },
          ),

          const SizedBox(height: 10),

          // 🔥 날짜 표시
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              "${_selectedDay.year}.${_selectedDay.month}.${_selectedDay.day}",
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const Divider(),

          // 🔥 기록 리스트
          Expanded(
            child: _selectedRecords.isEmpty
                ? const Center(child: Text("기록 없음"))
                : ListView.builder(
                    itemCount: _selectedRecords.length,
                    itemBuilder: (context, index) {
                      final r = _selectedRecords[index];
                      final duration =
                          r.endTime.difference(r.startTime);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(r.title),
                          subtitle: Text(
                              "${_formatTime(r.startTime)} ~ ${_formatTime(r.endTime)}"),
                          trailing: Text(_formatDuration(duration)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}