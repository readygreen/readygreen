import 'package:flutter/material.dart';
import 'package:readygreen/screens/loading/start_loading.dart'; // 로딩 페이지 import
import 'package:readygreen/screens/login/login.dart'; // 로그인 페이지
import 'package:readygreen/screens/home/home.dart'; // 메인 페이지 import

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // 처음에 로딩 페이지로 이동
      routes: {
        '/': (context) => StartLoadingPage(),
        '/login': (context) => LoginPage(),
        '/main': (context) => MainPage(),
      },
    );
  }
}
