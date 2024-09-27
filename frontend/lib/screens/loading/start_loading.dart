import 'package:flutter/material.dart';
import 'dart:async'; // for Timer
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage
import 'package:readygreen/screens/login/login.dart'; // 로그인 페이지
import 'package:readygreen/main.dart'; // 메인 페이지
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage


class StartLoadingPage extends StatefulWidget {
  const StartLoadingPage({super.key});

  @override
  _StartLoadingPageState createState() => _StartLoadingPageState();
}

class _StartLoadingPageState extends State<StartLoadingPage> {
  final FlutterSecureStorage secureStorage =
      FlutterSecureStorage(); // Secure Storage 객체 생성

  @override
  void initState() {
    super.initState();
    getMyDeviceToken();
    _checkLoginStatus(); // 앱 시작 시 로그인 상태 확인
  }
  void getMyDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("내 디바이스 토큰: $token");
  }

  // 저장된 accessToken 확인하여 자동 로그인 처리
  Future<void> _checkLoginStatus() async {
    String? accessToken = await secureStorage.read(key: 'accessToken');

    if (accessToken != null) {
      // accessToken이 있으면 MainPage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      // accessToken이 없으면 LoginPage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(), // 로딩 중 UI
      ),
    );
  }
}
