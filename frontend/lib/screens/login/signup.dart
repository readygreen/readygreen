import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    String email = emailController.text;
    String nickname = nicknameController.text;
    String password = passwordController.text; // 소셜 ID에 password
    String socialType = "GOOGLE"; // 소셜 로그인 타입 고정

    if (email.isNotEmpty &&
        nickname.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      // API 요청을 보내기 위한 URL
      final String apiUrl = "http://j11b108.p.ssafy.io/api/v1/auth";
      // 요청 바디
      Map<String, String> requestBody = {
        'email': email,
        'nickname': nickname,
        'socialId': password,
        'socialType': socialType,
      };

      try {
        // POST 요청 보내기
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode(requestBody),
        );

        // 서버 응답 확인
        if (response.statusCode == 200) {
          // 성공적으로 회원가입 처리된 경우
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입이 완료되었습니다! 로그인 페이지로 이동합니다.')),
          );
          Navigator.pop(context); // 로그인 페이지로 돌아가기
        } else {
          // 회원가입 실패 시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      } catch (e) {
        // 예외 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
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
              controller: nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signUp(context); // 회원가입 버튼 클릭 시 API 호출
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
