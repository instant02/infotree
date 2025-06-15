import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _majorController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final school = _schoolController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final majors =
          _majorController.text.split(',').map((e) => e.trim()).toList();
      final password = _passwordController.text;

      debugPrint('이름: $name');
      debugPrint('학교: $school');
      debugPrint('이메일: $email');
      debugPrint('전화번호: $phone');
      debugPrint('전공: $majors');
      debugPrint('비밀번호: $password');

      // 가입 정보 유효성 검증 통과 후
      Navigator.pushNamed(context, '/select_keywords');

      // TODO: 서버 전송 or DB 저장
    }
  }

  Widget styledLabeledField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
            children:
                isRequired
                    ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFCD3B2F)),
                      ),
                    ]
                    : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF876B55)),
            suffixIcon:
                obscureText
                    ? const Icon(Icons.visibility_off, color: Color(0xFF876B55))
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            filled: true,
            fillColor: Colors.white,
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
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('회원가입', style: TextStyle(color: Color(0xFF62462B))),
        iconTheme: const IconThemeData(color: Color(0xFF62462B)),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "회원이 되어 다양한 혜택을 경험해 보세요!",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Color(0xFFCD3B2F),
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: ' 표시는 필수 입력 항목입니다.',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  styledLabeledField(
                    label: '이름',
                    hint: '이름을 입력해주세요',
                    icon: Icons.person,
                    controller: _nameController,
                    isRequired: true,
                    validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '학교',
                    hint: '학교명을 입력해주세요',
                    icon: Icons.school,
                    controller: _schoolController,
                    isRequired: true,
                    validator: (value) => value!.isEmpty ? '학교를 입력하세요' : null,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '이메일',
                    hint: '이메일 주소 입력',
                    icon: Icons.email,
                    controller: _emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            (value == null || !value.contains('@'))
                                ? '유효한 이메일을 입력하세요'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '전화번호',
                    hint: '휴대폰 번호 입력',
                    icon: Icons.phone,
                    controller: _phoneController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? '전화번호를 입력하세요' : null,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '전공',
                    hint: '쉼표로 여러 전공 입력 가능',
                    icon: Icons.book,
                    controller: _majorController,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '비밀번호',
                    hint: '비밀번호 입력',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    isRequired: true,
                    obscureText: true,
                    validator:
                        (value) => value!.length < 6 ? '6자 이상 입력하세요' : null,
                  ),
                  const SizedBox(height: 16),

                  styledLabeledField(
                    label: '비밀번호 확인',
                    hint: '비밀번호 재입력',
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    isRequired: true,
                    obscureText: true,
                    validator:
                        (value) =>
                            value != _passwordController.text
                                ? '비밀번호가 일치하지 않습니다'
                                : null,
                  ),
                  const SizedBox(height: 30),

                  // 회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF377639),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '가입하기',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBEB8AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '가입취소',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
