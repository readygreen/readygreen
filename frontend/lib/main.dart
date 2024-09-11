import 'package:flutter/material.dart';
import 'package:readygreen/screens/loading/start_loading.dart'; // 로딩 페이지 import
import 'package:readygreen/screens/login/login.dart'; // 로그인 페이지
import 'package:readygreen/screens/home/home.dart'; // 홈 페이지 import
import 'package:readygreen/screens/map/map.dart'; // 지도 페이지 import

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartLoadingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/map': (context) => const MapPage(),
      },
    );
  }
}
