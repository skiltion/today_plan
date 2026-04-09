import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerState extends ChangeNotifier {
  static final TimerState instance = TimerState._internal();
  factory TimerState() => instance;
  TimerState._internal();
  
  bool isRunning = false;
  Duration elapsed = Duration.zero;
  String currentTitle = '';
  DateTime? startTime;

  /// 🔹 사용자가 직접 시작했는지
  bool hasStartedOnce = false;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();

    currentTitle = prefs.getString("timer_title") ?? "";
    elapsed = Duration(seconds: prefs.getInt("timer_seconds") ?? 0);

    // 앱 시작 시 자동 시작 방지
    isRunning = false;
    hasStartedOnce = prefs.getBool("timer_has_started") ?? false;

    final millis = prefs.getInt("timer_start_time");
    if (millis != null) {
      startTime = DateTime.fromMillisecondsSinceEpoch(millis);
    }

    notifyListeners();
  }

  void start(String title) async {
    currentTitle = title;
    isRunning = true;
    hasStartedOnce = true; // ✅ 사용자가 시작함
    elapsed = Duration.zero;
    startTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("timer_running", true);
    await prefs.setString("timer_title", title);
    await prefs.setInt("timer_seconds", 0);
    await prefs.setInt("timer_start_time", startTime!.millisecondsSinceEpoch);
    await prefs.setBool("timer_has_started", true);

    notifyListeners();
  }

  void pause() async {
    isRunning = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("timer_running", false);
    await prefs.setInt("timer_seconds", elapsed.inSeconds);
    notifyListeners();
  }

  void resume() async {
    if (!hasStartedOnce) return; // ✅ 자동 실행 방지
    isRunning = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("timer_running", true);
    notifyListeners();
  }

  // ================= 저장용 =================
  Map<String, DateTime>? buildRecord() {
    if (startTime == null || elapsed.inSeconds == 0) return null;
    final end = startTime!.add(elapsed);
    return {
      "start": startTime!,
      "end": end,
    };
  }

  // ================= 초기화 =================
  void reset() async {
    isRunning = false;
    elapsed = Duration.zero;
    currentTitle = '';
    startTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("timer_running");
    await prefs.remove("timer_title");
    await prefs.remove("timer_seconds");
    await prefs.remove("timer_start_time");

    notifyListeners();
  }

  
  // ================= 백그라운드 업데이트 =================
  void updateFromBackground(int seconds) async {
    elapsed = Duration(seconds: seconds);
    notifyListeners();
  }
}