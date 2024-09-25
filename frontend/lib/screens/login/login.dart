import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/screens/login/signup.dart';
// import 'package:readygreen/api/user_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final UserApi loginService = UserApi(); // LoginService 객체 생성
  Future<void> signInWithKakao() async {
  try {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }

        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }

    // 사용자 정보 요청 및 콘솔 출력
    User user = await UserApi.instance.me();
    print('User ID: ${user.id}');
    print('Nickname: ${user.kakaoAccount?.profile?.nickname}');
    print('Email: ${user.kakaoAccount?.email}');

  } catch (error) {
    print('로그인 도중 에러 발생: $error');
  }
}
  // Future<void> _login() async {
  //   String email = emailController.text;
  //   String password = passwordController.text;

  //   if (email.isNotEmpty && password.isNotEmpty) {
  //     try {
  //       // LoginService를 통해 로그인 시도
  //       String? accessToken = await loginService.login(email, password);

  //       if (accessToken != null) {
  //         print('로그인 성공, Access Token: $accessToken');
  //         // 로그인 성공 시 MainPage로 이동
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => MainPage()),
  //         );
  //       }
  //     } catch (e) {
  //       // 오류 발생 시 메시지 출력
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
  //       );
  //       print('로그인 실패: $e');
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('모든 필드를 입력해주세요.')),
  //     );
  //   }
  // }
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
              Image.asset('images/facebook.png', height: 30), // Kakao 이미지로 변경 필요
              const SizedBox(width: 10),
              const Text(
                "Sign In With Kakao",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
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
            // ElevatedButton(
            //   // onPressed: _login, // 로그인 버튼 클릭 시 API 호출
            //   onPressed: ,
            //   child: Text('Login'),
            // ),
            const SizedBox(height: 20),
            getKakaoLoginButton(),
            const SizedBox(height: 20),
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
