import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/screens/login/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final NewUserApi loginService = NewUserApi(); // LoginService 객체 생성
  final storage = const FlutterSecureStorage();

  /// 카카오 로그인 처리
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
          MaterialPageRoute(builder: (context) => const MainPage()),
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
            MaterialPageRoute(builder: (context) => const MainPage()),
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

  /// 일반 이메일 로그인 처리
  Future<void> signInWithEmailPassword() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // 이메일이나 비밀번호가 비어있을 때 에러 메시지 처리
      print('이메일과 비밀번호를 입력하세요.');
      return;
    }

    try {
      // 일반 로그인 요청
      String? accessToken = await loginService.login(
        email: email,
        password: password,
        nickname: '', // 일반 로그인의 경우 닉네임은 빈 문자열로 설정
        socialType: 'BASIC', // 일반 로그인의 소셜 타입을 EMAIL로 설정
        profileImg: '', // 일반 로그인에 프로필 이미지가 없으므로 빈 문자열로 설정
      );

      if (accessToken != null) {
        // 로그인 성공 시 메인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        print('로그인 실패');
      }
    } catch (error) {
      print('일반 로그인 도중 에러 발생: $error');
    }
  }

  /// 회원가입 페이지로 이동
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  /// 카카오 로그인 버튼 UI
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

  /// 일반 로그인 버튼 UI
  Widget getEmailLoginButton() {
    return InkWell(
      onTap: () {
        signInWithEmailPassword(); // 일반 로그인 요청 함수 호출
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue, // 버튼 색상 설정
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.email, color: Colors.white), // 이메일 아이콘
              SizedBox(width: 10),
              Text(
                "이메일로 로그인",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 회원가입 버튼 UI
  Widget getSignUpButton() {
    return InkWell(
      onTap: () {
        _navigateToSignUp(); // 회원가입 페이지로 이동
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green, // 회원가입 버튼 색상
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_add, color: Colors.white), // 회원가입 아이콘
              SizedBox(width: 10),
              Text(
                "회원가입",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            getEmailLoginButton(), // 일반 로그인 버튼
            const SizedBox(height: 20),
            getKakaoLoginButton(), // 카카오 로그인 버튼
            const SizedBox(height: 20),
            getSignUpButton(), // 회원가입 버튼
          ],
        ),
      ),
    );
  }
}
