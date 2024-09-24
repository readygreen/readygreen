import 'package:flutter/material.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/screens/login/signup.dart';
import 'package:readygreen/api/user_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserApi loginService = UserApi(); // LoginService 객체 생성

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // LoginService를 통해 로그인 시도
        String? accessToken = await loginService.login(email, password);

        if (accessToken != null) {
          print('로그인 성공, Access Token: $accessToken');
          // 로그인 성공 시 MainPage로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      } catch (e) {
        // 오류 발생 시 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
        );
        print('로그인 실패: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login, // 로그인 버튼 클릭 시 API 호출
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToSignUp, // 회원가입 페이지로 이동
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
