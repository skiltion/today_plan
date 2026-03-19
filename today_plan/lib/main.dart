import 'package:flutter/material.dart';
import 'features/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 중요

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루계획',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}