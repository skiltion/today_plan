import 'package:flutter/material.dart';

class TimerState extends ChangeNotifier {
  bool isRunning = false;
  Duration elapsed = Duration.zero;
  String currentTitle = '';

  DateTime? currentStart;
  List<Map<String, DateTime>> segments = [];

  // 시작
  void start(String title) {
    if (!isRunning) {
      currentTitle = title;
      currentStart = DateTime.now();
      isRunning = true;
      notifyListeners();
    }
  }

  // 일시정지
  void pause() {
    if (currentStart != null) {
      segments.add({
        'start': currentStart!,
        'end': DateTime.now(),
      });
    }

    currentStart = null;
    isRunning = false;
    _recalculate();
    notifyListeners();
  }

  // 시간 업데이트 (UI용)
  void tick() {
    if (isRunning && currentStart != null) {
      elapsed = _calculateTotal();
      notifyListeners();
    }
  }

  // 종료 (완전 초기화 X, 기록용 유지)
  void stop() {
    pause();
  }

  // 전체 시간 계산
  Duration _calculateTotal() {
    Duration total = Duration.zero;

    for (var s in segments) {
      total += s['end']!.difference(s['start']!);
    }

    if (isRunning && currentStart != null) {
      total += DateTime.now().difference(currentStart!);
    }

    return total;
  }

  void _recalculate() {
    elapsed = _calculateTotal();
  }

  // 초기화 (저장 후)
  void reset() {
    isRunning = false;
    elapsed = Duration.zero;
    currentTitle = '';
    currentStart = null;
    segments.clear();
    notifyListeners();
  }
}