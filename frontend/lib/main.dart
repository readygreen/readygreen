import 'package:flutter/material.dart';
import 'package:readygreen/screens/loading/start_loading.dart';
import 'package:readygreen/screens/login/login.dart';
import 'package:readygreen/screens/home/home.dart';
import 'package:readygreen/screens/map/map.dart';

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
