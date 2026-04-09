import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../core/notification_service.dart';

class BackgroundTimerService {
  static void start(String title) {
    final service = FlutterBackgroundService();
    service.startService();
    service.invoke("start", {"title": title});
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

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    int seconds = 0;
    bool isRunning = false;
    String currentTitle = "";

    // 초기 알림
    NotificationService.showRunningNotification("준비중");

    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isRunning) return;

      seconds++;
      service.invoke("update", {"seconds": seconds, "title": currentTitle});

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "타이머: $currentTitle",
          content: "$seconds 초 경과",
        );
      }
    });

    service.on("start").listen((event) {
      currentTitle = event?['title'] ?? '';
      seconds = 0;
      isRunning = true;
      NotificationService.showRunningNotification("타이머 시작: $currentTitle");
    });

    service.on("pause").listen((event) {
      isRunning = false;
      NotificationService.updateRunningNotification(currentTitle, seconds ~/ 60);
    });

    service.on("resume").listen((event) {
      isRunning = true;
      NotificationService.updateRunningNotification(currentTitle, seconds ~/ 60);
    });

    service.on("stop").listen((event) {
      isRunning = false;
      timer?.cancel();
      NotificationService.cancelRunningNotification();
      service.stopSelf();
    });
  }
}