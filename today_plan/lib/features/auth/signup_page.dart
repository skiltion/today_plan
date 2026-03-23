import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _auth = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signup() async {
    try {
      final user = await _auth.signUp(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("회원가입 성공 🎉"),
            duration: Duration(seconds: 1),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        Navigator.pop(context); // 로그인 페이지로 복귀
      }
    } catch (e) {
      String message = "회원가입 실패";

      if (e.toString().contains('weak-password')) {
        message = "비밀번호는 6자 이상이어야 합니다";
      } else if (e.toString().contains('email-already-in-use')) {
        message = "이미 사용중인 이메일입니다";
      } else if (e.toString().contains('invalid-email')) {
        message = "올바른 이메일 형식이 아닙니다";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "이메일")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "비밀번호"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: const Text("회원가입")),
          ],
        ),
      ),
    );
  }
}