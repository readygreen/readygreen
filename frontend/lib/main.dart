import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
// import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../../firebase_options.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage
import 'package:flutter/services.dart'; // SystemNavigator를 사용하기 위해 필요

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // 알림 채널 ID
    'High Importance Notifications', // 채널 이름
    importance: Importance.max,
    playSound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel', 'high_importance_notification',
          importance: Importance.max));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  ));
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // 포그라운드 알림 설정
    service.setAsForegroundService();

    // Foreground 알림 업데이트
    service.setForegroundNotificationInfo(
      title: "Foreground Service",
      content: "Background service is running...",
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    double targetLatitude = 37.7749;
    double targetLongitude = -122.4194;
    int greenDuration = 40; // 초록불 지속 시간 (초)
    int redDuration = 110; // 빨간불 지속 시간 (초)
    int totalDuration = greenDuration + redDuration; // 총 주기 (초)
    String startTimeString = "00:01:23"; // hh:mm:ss
    List<String> startTimeParts = startTimeString.split(':');
    DateTime startTime = DateTime.now().copyWith(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
      second: int.parse(startTimeParts[2]),
    );
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;
    double distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      targetLatitude,
      targetLongitude,
    );
    if (distance <= 15) {
      DateTime now = DateTime.now();
      int secondsSinceStart =
          now.difference(startTime).inSeconds % totalDuration;

      // 파란불 켜지기 5초 전이면
      if (secondsSinceStart >= (redDuration - 5) &&
          secondsSinceStart < redDuration) {
        await showNotification(); // 알림 전송
      }
    }
  });

  // 주기적인 작업 수행
  // Timer.periodic(const Duration(seconds: 5), (timer) async {
  //   if (service is AndroidServiceInstance) {
  //     if (await service.isForegroundService()) {
  //       // 포그라운드 알림을 주기적으로 업데이트
  //       flutterLocalNotificationsPlugin.show(
  //         0,
  //         '포그라운드 서비스',
  //         '서비스가 실행 중입니다: ${DateTime.now()}',
  //         const NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             'high_importance_channel',
  //             '포그라운드 알림',
  //             importance: Importance.max,
  //             priority: Priority.high,
  //             ongoing: true,
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   print('Background Service: Running at ${DateTime.now()}');
  //   service.invoke('update');
  // });
}

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
  DateTime? backPressedTime;
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
