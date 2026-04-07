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

    // 🔥 클릭 이벤트 없음 (앱만 열림)
    await _notifications.initialize(settings);

    // 🔥 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final prefs = await SharedPreferences.getInstance();
    final isScheduled = prefs.getBool('notification_scheduled') ?? false;

    if (!isScheduled) {
      await scheduleDailyNotifications();
      await prefs.setBool('notification_scheduled', true);
    }
  }

  static Future<void> scheduleDailyNotifications() async {
    await _schedule(1, 9, "🌅 아침 점검", "오늘 계획 확인!");
    await _schedule(2, 13, "🍽 점심 점검", "진행 체크!");
    await _schedule(3, 21, "🌙 밤 점검", "기록 작성!");
  }

  static Future<void> _schedule(
      int id, int hour, String title, String body) async {
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
  );
}

static Future<void> updateRunningNotification(
    String title, int minutes) async {
  await _notifications.show(
    999,
    "⏱ 진행중",
    "$title - ${minutes}분 진행중",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'running_channel',
        'Running Timer',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
      ),
    ),
  );
}

static Future<void> cancelRunningNotification() async {
  await _notifications.cancel(999);
}
}