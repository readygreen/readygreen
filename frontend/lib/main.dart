import 'package:flutter/material.dart';
import 'package:readygreen/screens/loading/start_loading.dart';
import 'package:readygreen/screens/login/login.dart';
import 'package:readygreen/screens/home/home.dart';
import 'package:readygreen/screens/point/point.dart';
import 'package:readygreen/screens/map/map.dart';
import 'package:readygreen/screens/place/place.dart';
import 'package:readygreen/screens/mypage/mypage.dart';

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
        '/login': (context) => LoginPage(),
        // '/home': (context) => const HomePage(), // MainScreen으로 변경
        // '/map': (context) => const MapPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    PointPage(),
    const MapPage(),
    const PlacePage(),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7FC818),
        unselectedItemColor: const Color(0xFF7A7A7A),
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        // elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '포인트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: '추천',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
