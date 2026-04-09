import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _notifications.initialize(settings);

    // 🔥 채널 생성 (핵심)
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'timer_channel',
        'Timer Service',
        description: '백그라운드 타이머',
        importance: Importance.low,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'running_channel',
        'Running Timer',
        description: '실행 중 타이머',
        importance: Importance.max,
      ),
    );

    // 권한 요청
    await androidPlugin?.requestNotificationsPermission();

    final prefs = await SharedPreferences.getInstance();
    final isScheduled = prefs.getBool('notification_scheduled') ?? false;

    if (!isScheduled) {
      await scheduleDailyNotifications();
      await prefs.setBool('notification_scheduled', true);
    }
  }

  // ================== 실시간 타이머 알림 ==================

  static Future<void> showRunningNotification(String title) async {
    await _notifications.show(
      999,
      "⏱ 진행중",
      "$title 시작됨",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'running_channel',
          'Running Timer',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
        ),
      ),
      payload: "timer",
    );
  }

  static Future<void> updateRunningNotification(
      String title, int seconds) async {
    final minutes = (seconds ~/ 60);
    final sec = seconds % 60;

    await _notifications.show(
      999,
      "⏱ $title",
      "${minutes}분 ${sec}초 진행중",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'running_channel',
          'Running Timer',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
        ),
      ),
      payload: "timer",
    );
  }

  static Future<void> cancelRunningNotification() async {
    await _notifications.cancel(999);
  }

  // ================== 기존 예약 알림 ==================

  static Future<void> scheduleDailyNotifications() async {
    await _schedule(1, 9, "🌅 아침 점검", "오늘 계획 확인!");
    await _schedule(2, 13, "🍽 점심 점검", "진행 체크!");
    await _schedule(3, 21, "🌙 밤 점검", "기록 작성!");
  }

  static Future<void> _schedule(
      int id, int hour, String title, String body) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // 🔥 변경
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("알림 스케줄 실패 (권한 문제): $e");
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}