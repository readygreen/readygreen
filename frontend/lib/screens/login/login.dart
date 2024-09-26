import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:readygreen/main.dart';
// import 'package:readygreen/screens/login/signup.dart';
import 'package:readygreen/api/user_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final NewUserApi loginService = NewUserApi(); // LoginService 객체 생성
  Future<void> signInWithKakao() async {
    try {
      print('카카오 로그인 KakaoSdk.origin');
      print(await KakaoSdk.origin);

      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }

      // 사용자 정보 요청 및 콘솔 출력
      User user = await UserApi.instance.me();
      print('User ID: ${user.id}');
      print('Nickname: ${user.kakaoAccount?.profile?.nickname}');
      print('Email: ${user.kakaoAccount?.email}');
      print('Profile Image: ${user.kakaoAccount?.profile?.profileImageUrl}');

      // 로그인 시도
      String? accessToken = await loginService.login(
        email: user.kakaoAccount?.email ?? '',
        password: user.id.toString(), // 카카오 고유 ID를 비밀번호로 사용
        nickname: user.kakaoAccount?.profile?.nickname ?? '',
        socialType: 'KAKAO',
        profileImg: user.kakaoAccount?.profile?.profileImageUrl ?? '',
      );

      if (accessToken != null) {
        // 로그인 성공 시 메인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        // 로그인 실패 시 회원가입 시도
        print('로그인 실패, 회원가입 시도 중...');

        bool signUpSuccess = await loginService.signUp(
          email: user.kakaoAccount?.email ?? '',
          nickname: user.kakaoAccount?.profile?.nickname ?? '',
          password: user.id.toString(),
          socialType: 'KAKAO',
          profileImg: user.kakaoAccount?.profile?.profileImageUrl ?? '',
        );

        if (signUpSuccess) {
          // 회원가입 성공 시 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } else {
          // 회원가입 실패 시 에러 처리
          print('회원가입 실패');
        }
      }
    } catch (error) {
      print('로그인 도중 에러 발생: $error');
    }
  }

  Widget getKakaoLoginButton() {
    return InkWell(
      onTap: () {
        signInWithKakao();
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/badge.png',
                  height: 30), // Kakao 이미지로 변경 필요
              const SizedBox(width: 10),
              const Text(
                "카카오로 실행하기",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _navigateToSignUp() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => SignUpPage()),
  //   );
  // }

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
            const SizedBox(height: 20),
            getKakaoLoginButton(),
            const SizedBox(height: 20),
            SizedBox(height: 10),
            // TextButton(
            //   onPressed: _navigateToSignUp, // 회원가입 페이지로 이동
            //   child: Text('회원가입'),
            // ),
          ],
        ),
      ),
    );
  }
}
