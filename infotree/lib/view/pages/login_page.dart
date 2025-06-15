import 'package:flutter/material.dart';
import 'package:infotree/model/user_data.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infotree/model/data.dart';

import 'root_page.dart';
import 'signup_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _tryLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('이메일을 입력하세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (res.statusCode == 200) {
        final userJson = jsonDecode(res.body)['user'];

        final userData = UserData.fromJson(userJson);

        // Provider에 유저 정보 저장
        Provider.of<Data>(context, listen: false).user = userData;

        // 페이지 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RootPage()),
        );
      } else {
        _showSnackBar('로그인 실패: ${jsonDecode(res.body)['error']}');
      }
    } catch (e) {
      print('로그인 오류: $e');
      _showSnackBar('서버에 연결할 수 없습니다.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100.0),
            const Text(
              'InfoTree',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF62462B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '학생 혜택 정보를 한눈에!',
              style: TextStyle(fontSize: 16, color: Color(0xFF876B55)),
            ),
            const SizedBox(height: 48),

            // 이메일 입력
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: '이메일',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF876B55),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF876B55)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFF62462B),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 비밀번호 입력
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF876B55),
                ),
                suffixIcon: const Icon(
                  Icons.visibility_off,
                  color: Color(0xFF876B55),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFF876B55)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFF62462B),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 로그인 버튼
            Center(
              child: SizedBox(
                width: 230.0,
                height: 50,
                child: ElevatedButton(
                  onPressed: _tryLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF377639),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const SignUpScreen(), // 회원가입 화면으로 이동
                    ),
                  );
                },
                child: const Text(
                  '계정이 없으신가요? 회원가입',
                  style: TextStyle(color: Color(0xFF876B55)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
