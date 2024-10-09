import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/loading/start_loading.dart';
import 'package:readygreen/screens/login/login.dart';
import 'package:readygreen/screens/home/home.dart';
import 'package:readygreen/screens/map/mapdirection.dart';
import 'package:readygreen/screens/point/point.dart';
import 'package:readygreen/screens/map/map.dart';
import 'package:readygreen/screens/place/place.dart';
import 'package:readygreen/screens/mypage/mypage.dart';
import 'package:provider/provider.dart';
import 'provider/current_location.dart';
import 'package:readygreen/screens/point/pointDetail.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../../firebase_options.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
}

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel', 'high_importance_notification',
          importance: Importance.max));
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  ));
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeNotification();
  KakaoSdk.init(
    nativeAppKey: 'cf5488929a2ad2db61f895c42f6926cc',
    javaScriptAppKey: 'dc542207fe96b123abf798c0113bd537',
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CurrentLocationProvider(),
        ), // CurrentLocationProvider 등록
      ],
      child: MaterialApp(
        title: 'Flutter Navigation Example',
        theme: ThemeData(
          fontFamily: 'CustomFont',
          // primarySwatch: Colors.green,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const StartLoadingPage(),
          '/login': (context) => const LoginPage(),
          // '/home': (context) => const HomePage(), // MainScreen으로 변경
          '/map': (context) => const MapPage(),
        },
      ),
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
  var messageString = "";
  // Secure Storage 객체 생성

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    PointPage(),
    const MapPage(),
    PlacePage(),
    const MyPage(),
    PointDetailPage()
  ];
  // 저장된 accessToken 확인하여 자동 로그인 처리

  @override
  void initState() {
    print("init하는중");
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("메시지 수신!");
      if (message.data['type'] == 1) {
        if (message.data['type'] == '1') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapDirectionPage()),
          );
        }
      } else if (message.data['type'] == '2') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
      // Notification 메시지 출력 (알림)
      if (message.notification != null) {
        print('알림 제목: ${message.notification!.title}');
        print('알림 본문: ${message.notification!.body}');
      }

      // 데이터 메시지 출력 (데이터)
      if (message.data.isNotEmpty) {
        print('데이터 메시지: ${message.data}');
        // 예: message.data['type'] 확인
        if (message.data.containsKey('type')) {
          String type = message.data['type'];
          print('받은 메시지 타입: $type');
          if (type == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapDirectionPage()),
            );
          } else if (type == '2') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          }
        }
      }
      if (!mounted) return;
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
          ),
        );
        setState(() {
          messageString = message.notification!.body!;
          print(message.notification);
          print("Foreground 메시지 수신: $messageString");
        });
      }
    });
  }

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
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.greytext,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        // elevation: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/nothome.png', // 선택되지 않았을 때 이미지
              width: 20,
              height: 20,
            ),
            activeIcon: Image.asset(
              'assets/icon/home.png', // 선택되었을 때 이미지
              width: 20,
              height: 20,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/notpoint.png', // 선택되지 않았을 때 이미지
              width: 22,
              height: 22,
            ),
            activeIcon: Image.asset(
              'assets/icon/point.png', // 선택되었을 때 이미지
              width: 22,
              height: 22,
            ),
            label: '포인트',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/notmap.png', // 선택되지 않았을 때 이미지
              width: 22,
              height: 22,
            ),
            activeIcon: Image.asset(
              'assets/icon/map.png', // 선택되었을 때 이미지
              width: 22,
              height: 22,
            ),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/notlocation.png', // 선택되지 않았을 때 이미지
              width: 23,
              height: 23,
            ),
            activeIcon: Image.asset(
              'assets/icon/location.png', // 선택되었을 때 이미지
              width: 23,
              height: 23,
            ),
            label: '주변',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/notprofile.png', // 선택되지 않았을 때 이미지
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icon/profile.png', // 선택되었을 때 이미지
              width: 24,
              height: 24,
            ),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
