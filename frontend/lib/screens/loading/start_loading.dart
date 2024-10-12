import 'package:flutter/material.dart';
import 'dart:async'; // for Timer
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/login/login.dart'; // 로그인 페이지
import 'package:readygreen/main.dart'; // 메인 페이지
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:readygreen/screens/map/mapdirection.dart';
// import '../../firebase_options.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage

class StartLoadingPage extends StatefulWidget {
  const StartLoadingPage({super.key});
  @override
  _StartLoadingPageState createState() => _StartLoadingPageState();
}

class _StartLoadingPageState extends State<StartLoadingPage> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final MapStartAPI mapStartAPI = MapStartAPI();
  final NewUserApi newUserApi = NewUserApi();

  @override
  void initState() {
    super.initState();
    getMyDeviceToken();
    _checkLoginStatus(); // 앱 시작 시 로그인 상태 확인
  }

  void getMyDeviceToken() async {
    final deviceToken = await FirebaseMessaging.instance.getToken();

    print("내 디바이스 토큰: $deviceToken");
    await storage.write(key: 'deviceToken', value: deviceToken ?? '');
  }

  // 저장된 accessToken 확인하여 자동 로그인 처리
  Future<void> _checkLoginStatus() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (await mapStartAPI.checkIsGuide()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapDirectionPage()),
      );
      return;
    }
    // if()
    final profile = await newUserApi.getProfile();
    if (profile != null) {
      // accessToken이 있으면 MainPage로 이동
      Navigator.push(
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
      backgroundColor: Colors.white,
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
        ), // 로딩 중 UI
      ),
    );
  }
}
