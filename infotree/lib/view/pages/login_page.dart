import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _tryLogin() {
    final id = _emailController.text.trim();
    final pw = _passwordController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      _showSnackBar("아이디와 비밀번호를 모두 입력하세요.");
    } else if (id == "infotree" && pw == "info1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } else {
      _showSnackBar("아이디 또는 비밀번호가 올바르지 않습니다.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100.0),
              Text(
                'InfoTree',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF62462B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
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
                controller: _passwordController,
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
              const SizedBox(height: 24),

              // 회원가입 이동
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '계정이 없으신가요? 회원가입',
                    style: TextStyle(color: Color(0xFF876B55)),
                  ),
                ),
              ),

              // 관리자용
              Center(
                child: TextButton(
                  onPressed: () {
                    // 관리자 동작
                  },
                  child: const Text(
                    '구독 채널 관리자는 여기를 클릭',
                    style: TextStyle(color: Color(0xFF876B55)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
