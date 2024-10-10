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
  int index = 0;
  bool flag = false;
  if (service is AndroidServiceInstance) {
    print("백그라운드 서비스 시작");
    DartPluginRegistrant.ensureInitialized();
    service.setAsForegroundService();

    service.setForegroundNotificationInfo(
      title: "언제그린",
      content: "길 안내가 실행 중 입니다...",
    );

    Map<String, dynamic>? mapData = await mapStartAPI.fetchGuideInfo();
    List<dynamic>? blinkerDTOs = null;
    // Check if mapData is not null and contains the 'blinkerDTOs' key
    if (mapData != null && mapData.containsKey('blinkerDTOs')) {
      blinkerDTOs = mapData['blinkerDTOs'];
    }

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      String? isModiString = await storage.read(key: 'isModified');
      bool? done = isModiString != null ? isModiString == 'true' : false;

      if (done) {
        await storage.write(key: 'isModified', value: 'false');
        service.stopSelf();
      }

      print("isModiString: $done");

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Fetch the guide info which contains the blinkerDTOs
      Map<String, dynamic>? mapData = await mapStartAPI.fetchGuideInfo();
      List<dynamic>? blinkerDTOs = mapData?['blinkerDTOs'];

      // Ensure blinkerDTOs is not null or empty
      if (blinkerDTOs != null && blinkerDTOs.isNotEmpty) {
        for (var blinker in blinkerDTOs) {
          double blinkerLat = blinker['latitude'];
          double blinkerLng = blinker['longitude'];

          // Calculate the distance between current position and blinkerDTO coordinates
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            blinkerLat,
            blinkerLng,
          );

          // Check if the distance is within 10 meters
          if (distance <= 10) {
            print("Within 10 meters of blinkerDTO: Latitude: $blinkerLat, Longitude: $blinkerLng");

            if (await service.isForegroundService()) {
              flutterLocalNotificationsPlugin.show(
                0,
                '레디그린',
                '신호등이 곧 켜집니다.',
                // : ${position.latitude} ${position.longitude}',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'high_importance_channel',
                    '포그라운드 알림',
                    importance: Importance.low,
                    priority: Priority.low,
                    ongoing: false,
                  ),
                ),
              );
            }
          }
        }
      } else {
        print("No blinkerDTOs found.");
      }
    });
  }
}
