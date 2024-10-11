import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart'; // SystemNavigator를 사용하기 위해 필요
import 'package:readygreen/background/background_service.dart'; 

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final storage = const FlutterSecureStorage();
Future<void> initializeNotification() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // 알림 채널 ID
    'High Importance Notifications', // 채널 이름
    importance: Importance.max,
    playSound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> main() async {
  await dotenv.load(fileName: 'config/.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeNotification();
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_LOGIN_NATIVE_KEY'],
    javaScriptAppKey: dotenv.env['KAKAO_LOGIN_JS_KEY'],
  );
  runApp(const App());
}

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     Timer.periodic(const Duration(seconds: 5), (timer) async {

//       String? isGuideString = await storage.read(key: 'isGuide');
//       bool? isGuide = isGuideString != null ? isGuideString == 'true' : false;

//       String? isModiString = await storage.read(key: 'isModified');
//       bool? isModi = isModiString != null ? isModiString == 'true' : false;
//       print("isModiString");
//       print(isModiString);
//       print("isGuideString");
//       print(isGuideString);
      
//       // 주기적으로 포그라운드 알림 업데이트
//       if (isGuide && await service.isForegroundService()) {
//         Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//         flutterLocalNotificationsPlugin.show(
//           0,
//           '포그라운드 서비스',
//           '서비스가 실행 중입니다: ${position.latitude} ${position.longitude}',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'high_importance_channel',
//               '포그라운드 알림',
//               importance: Importance.high,
//               priority: Priority.high,
//               ongoing: false,
//             ),
//           ),
//         );
//       }
//       if(isModi){
//         if(isGuide){
//           print("알림 고정 시작");
//           DartPluginRegistrant.ensureInitialized();
//           service.setAsForegroundService();

//           // Foreground 알림 업데이트
//           service.setForegroundNotificationInfo(
//             title: "언제그린",
//             content: "길 안내가 실행 중 입니다...",
//           );
//           //라우트 데이터 받아오기

//         }else{
//           print("알림 고정 종료");
//           service.stopSelf();
//         }
//         await storage.write(key: 'isModified', value: 'false');
//       }
//     });
//   }
// }

Future<void> showNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', // 채널 ID
    'channel_name', // 채널 이름
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // 알림 ID
    '알림', // 알림 제목
    '파란불이 곧 켜집니다.', // 알림 내용
    platformChannelSpecifics,
    payload: '파란불 알림', // 선택사항: 알림 클릭 시 전달할 데이터
  );
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
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const StartLoadingPage(),
          '/login': (context) => const LoginPage(),
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

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  var messageString = "";
  DateTime? backPressedTime;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    PointPage(),
    const MapPage(),
    PlacePage(),
    const MyPage(),
    PointDetailPage()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 상태 감지 옵저버 추가
    print("init하는중");

// 서비스 초기화 호출

    // Firebase 메시지 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("메시지 수신!");
      if (message.data['type'] == '1') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapDirectionPage()),
        );
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

      // // 데이터 메시지 출력 (데이터)
      // if (message.data.isNotEmpty) {
      //   String type = message.data['type'];
      //   print('받은 메시지 타입: $type');
      //   if (type == '1') {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const MapDirectionPage()),
      //     );
      //   } else if (type == '2') {
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => const MainPage()),
      //     );
      //   }
      // }

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 제거
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // 앱 상태 변경 감지
  //   if (state == AppLifecycleState.paused) {
  //     // 앱이 백그라운드로 전환되었을 때 알림을 띄움
  //     showNotification();
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로 가기 제어: false로 설정하여 기본 동작을 막음
      onPopInvoked: (bool didPop) {
        DateTime nowTime = DateTime.now();
        if (didPop == false &&
            (backPressedTime == null ||
                  nowTime.difference(backPressedTime!) >
                      const Duration(seconds: 2))) {
            // 2초 내로 다시 누르면 앱 종료
          backPressedTime = nowTime;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("한 번 더 누르면 앱이 종료됩니다."),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
            // 2초 안에 두 번 누르면 앱 종료
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
                  width: 21,
                  height: 21,
                ),
                activeIcon: Image.asset(
                  'assets/icon/home.png', // 선택되었을 때 이미지
                  width: 21,
                  height: 21,
                ),
              label: '홈',
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icon/notpoint.png', // 선택되지 않았을 때 이미지
                  width: 23,
                  height: 23,
                ),
                activeIcon: Image.asset(
                  'assets/icon/point.png', // 선택되었을 때 이미지
                  width: 23,
                  height: 23,
                ),
              label: '포인트',
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icon/notmap.png', // 선택되지 않았을 때 이미지
                  width: 21,
                  height: 21,
                ),
                activeIcon: Image.asset(
                  'assets/icon/map.png', // 선택되었을 때 이미지
                  width: 21,
                  height: 21,
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
                  width: 23,
                  height: 23,
                ),
                activeIcon: Image.asset(
                  'assets/icon/profile.png', // 선택되었을 때 이미지
                  width: 23,
                  height: 23,
                ),
              label: '프로필',
            ),
          ],
        ),
        ));
  }
}
