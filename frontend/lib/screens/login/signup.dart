import 'package:flutter/material.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/main.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController(); // 비밀번호 확인 컨트롤러

  final NewUserApi userApi = NewUserApi();

  Future<void> _signUp(BuildContext context) async {
    String email = emailController.text;
    String nickname = nicknameController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text; // 비밀번호 확인 값
    String socialType = "BASIC";
    String profileImg = '';

    if (email.isNotEmpty &&
        nickname.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      // 비밀번호가 일치할 때 회원가입 요청
      bool success = await userApi.signUp(
          email: email,
          nickname: nickname,
          password: password,
          socialType: socialType,
          profileImg: profileImg);

      if (success) {
        // 회원가입 성공 후 자동 로그인 시도
        String? accessToken = await userApi.login(
          email: email,
          password: password,
          nickname: nickname,
          socialType: socialType,
          profileImg: profileImg,
        );

        if (accessToken != null) {
          // 로그인 성공 시 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), // 메인 페이지로 이동
          );
        } else {
          // 로그인 실패 시 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입은 완료되었지만 로그인에 실패했습니다.')),
          );
        }
      } else {
        // 회원가입 실패 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
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
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
            ),
            SizedBox(height: 16),
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
