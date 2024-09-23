import 'package:flutter/material.dart';
import 'dart:async'; // for Timer
import 'package:readygreen/screens/login/login.dart'; // 로그인 페이지

class StartLoadingPage extends StatefulWidget {
  const StartLoadingPage({super.key});

  @override
  _StartLoadingPageState createState() => _StartLoadingPageState();
}

class _StartLoadingPageState extends State<StartLoadingPage> {
  @override
  void initState() {
    super.initState();
    // 3초 뒤에 로그인 페이지로 이동
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
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
