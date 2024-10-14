import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/api/map_api.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final MapStartAPI mapStartAPI = MapStartAPI();
final storage = const FlutterSecureStorage();

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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await storage.write(key: 'isModified', value: 'false');
  int index = 0;
  bool flag = false;
  if (service is AndroidServiceInstance) {
    print("[서비스 시작] 백그라운드 서비스 시작");
    DartPluginRegistrant.ensureInitialized();
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: "언제그린",
      content: "길 안내가 실행 중 입니다...",
    );

    // 초기 API 호출
    Map<String, dynamic>? mapData = await mapStartAPI.fetchGuideInfo();
    List<dynamic>? blinkerDTOs;
    if (mapData != null && mapData.containsKey('blinkerDTOs')) {
      blinkerDTOs = mapData['blinkerDTOs'];
    } else {
      print("[API 호출 실패] blinkerDTOs 없음");
    }

    Timer.periodic(const Duration(seconds: 5), (timer) async {

      // 'isModified' 값을 읽어서 변경 여부를 확인
      String? isModiString = await storage.read(key: 'isModified');
      bool? done = isModiString != null ? isModiString == 'true' : false;
      bool alreadyNoti = false;

      // 'isModified'가 true면 서비스를 종료
      if (done) {
        await storage.write(key: 'isModified', value: 'false');
        service.stopSelf();
        return;  // 종료 시 이후 로직을 실행하지 않도록 함
      }

      // 현재 위치 정보 가져오기
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

      // API에서 'blinkerDTOs' 정보 다시 가져오기
      // Map<String, dynamic>? mapData = await mapStartAPI.fetchGuideInfo();
      List<dynamic>? blinkerDTOs = mapData?['blinkerDTOs'];

      if (blinkerDTOs != null && blinkerDTOs.isNotEmpty) {
        for (var blinker in blinkerDTOs) {
          // 신호등의 파란불 및 빨간불 지속 시간 추출
          int greenDuration = blinker['greenDuration'];
          int redDuration = blinker['redDuration'];
          int totalDuration = greenDuration + redDuration;
          String blinkerStartTime = blinker['startTime'];

          // 시작 시간을 기준으로 현재 주기 계산
          DateTime now = DateTime.now();
          List<String> startTimeParts = blinkerStartTime.split(':');
          DateTime startTime = DateTime(now.year, now.month, now.day,
              int.parse(startTimeParts[0]), int.parse(startTimeParts[1]), int.parse(startTimeParts[2]));
          int secondsSinceStart = now.difference(startTime).inSeconds % totalDuration;
          int next = totalDuration - secondsSinceStart;
          print("secondsSinceStart");
          print("Next value: $next");  // 현재 next 값 확인
          print("Condition result (next <= 7 && next >= 2): ${next <= 7 && next >= 0}");  // 조건 결과 확인
          // 파란불이 켜지기 2~7초 전일 때 알림 전송
          if (next <= 10 && next >=0) {
            alreadyNoti = true;
            Timer(Duration(seconds: 10), () {
              alreadyNoti = false; // 10초 후에 알림 가능 상태로 변경
              print("[알림 상태] 알림 가능 상태로 복귀");
            });
            // 신호등의 위도, 경도 정보 추출
            double blinkerLat = blinker['latitude'];
            double blinkerLng = blinker['longitude'];

            // 현재 위치와 신호등 위치 간 거리 계산
            double distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              blinkerLat,
              blinkerLng,
            );
            print("[거리 계산] 현재 위치와 신호등 간 거리: $distance m");

            // 신호등과 현재 위치가 10m 이내일 때만 처리
            if (distance <= 10) {
              print("[알림 준비] 10m 이내, 파란불 켜지기 직전");
              if (await service.isForegroundService()) {
                flutterLocalNotificationsPlugin.show(
                  0,
                  '언제그린',
                  '신호등이 곧 켜집니다.',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'high_importance_channel',
                      '포그라운드 알림',
                      importance: Importance.high,
                      priority: Priority.high,
                      ongoing: false,
                    ),
                  ),
                );
                print("[알림 전송] 신호등 알림 전송");
              }
            }
          }
        }
      } else {
        print("[신호등 정보 없음] blinkerDTOs 정보가 없습니다.");
      }
    });
  }
}
