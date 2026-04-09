import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../core/notification_service.dart';

class BackgroundTimerService {
  static void start(String title) {
    final service = FlutterBackgroundService();
    service.startService();
  }

  static void pause() {
    FlutterBackgroundService().invoke("pause");
  }

  static void resume() {
    FlutterBackgroundService().invoke("resume");
  }

  static void stop() {
    FlutterBackgroundService().invoke("stop");
  }

  static void reset() {
    FlutterBackgroundService().invoke("reset");
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    int seconds = 0;
    bool isRunning = false;
    String currentTitle = "";

    // 🔹 Foreground Notification 초기화 (Android 5~13 안전)
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "타이머 준비중",
        content: "0분 0초",
      );
    }

    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isRunning) return;

      seconds++;
      service.invoke("update", {"seconds": seconds, "title": currentTitle});

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "타이머: $currentTitle",
          content: "${seconds ~/ 60}분 ${seconds % 60}초 진행중",
        );
      }
    });

    service.on("start").listen((event) {
      currentTitle = event?['title'] ?? '';
      seconds = 0;
      isRunning = true;

      NotificationService.showRunningNotification(
        "$currentTitle 타이머 실행 중",
      );
    });

    service.on("pause").listen((event) {
      isRunning = false;
      NotificationService.updateRunningNotification(currentTitle, seconds);
    });

    service.on("resume").listen((event) {
      isRunning = true;
      NotificationService.updateRunningNotification(currentTitle, seconds);
    });

    service.on("stop").listen((event) {
      isRunning = false;
      timer?.cancel();
      NotificationService.cancelRunningNotification();
      service.stopSelf();
    });

    service.on("reset").listen((event) {
      seconds = 0;
      isRunning = false;
      NotificationService.updateRunningNotification(currentTitle, seconds);
    });
  }
}