import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'data/services/timer_state.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase 반드시 먼저 초기화
  await Firebase.initializeApp();

  // 🔥 백그라운드 서비스 초기화
  await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerState()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🔥 백그라운드 서비스 설정
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'timer_channel',
      initialNotificationTitle: '타이머 실행 중',
      initialNotificationContent: '0초',
    ),
    iosConfiguration: IosConfiguration(),
  );
}

/// 🔥 백그라운드 실행 함수
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  int seconds = 0;
  bool isPaused = false;

  service.on('pause').listen((event) {
    isPaused = true;
  });

  service.on('resume').listen((event) {
    isPaused = false;
  });

  Future.doWhile(() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!isPaused) {
      seconds++;

      service.invoke('update', {"seconds": seconds});

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "타이머 실행 중",
          content: "$seconds 초",
        );
      }
    }

    return true;
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(), // ✅ 바로 홈으로 이동
    );
  }
}