import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:intl/intl.dart';

// 동그라미 모양 마커를 텍스트와 함께 생성하는 함수
Future<BitmapDescriptor> createCircleMarker(
    String text, Color circleColor) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  const Size size = Size(70, 70); // 마커 크기 설정

  // 동그라미 배경
  Paint paint = Paint()..color = circleColor;
  canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), size.width / 2, paint);

  // 텍스트 스타일
  TextPainter painter = TextPainter(
    textDirection: ui.TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  painter.text = TextSpan(
    text: text,
    style: const TextStyle(
      fontSize: 30.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  painter.layout();

  // 텍스트를 동그라미 안에 넣기
  painter.paint(
      canvas, Offset(size.width * 0.23, size.height * 0.25)); // 텍스트 위치 조정

  final img = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
}

class TrafficLightService {
  final MapStartAPI api = MapStartAPI();
  Timer? _globalTimer; // 하나의 전역 타이머
  final Map<String, Map<String, dynamic>> _trafficLightData =
      {}; // 신호등 데이터를 저장하는 Map

  // 신호등 정보를 받아와 마커로 지도에 표시하는 함수
  Future<void> addTrafficLightsToMap({
    required double latitude,
    required double longitude,
    required Set<Marker> markers,
    required Function(Set<Marker>) onMarkersUpdated,
  }) async {
    const int radius = 400; // 반경 400미터

    // 신호등 정보 요청
    final List<dynamic>? trafficLightData = await api.fetchBlinkerInfo(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    if (trafficLightData != null) {
      Set<Marker> newMarkers = {};

      for (var trafficLight in trafficLightData) {
        double lat = trafficLight['latitude'];
        double lng = trafficLight['longitude'];
        String currentState = trafficLight['currentState'];
        int remainingTime = trafficLight['remainingTime'];
        int greenDuration = trafficLight['greenDuration'];
        int redDuration = trafficLight['redDuration'];

        // 상태에 따른 색상 설정
        Color circleColor =
            currentState == "RED" ? AppColors.red : AppColors.green;

        // 커스텀 마커 생성 및 초기 표시
        BitmapDescriptor customMarker =
            await createCircleMarker('$remainingTime', circleColor);

        // 신호등의 Marker 추가
        Marker trafficMarker = Marker(
          markerId: MarkerId(trafficLight['id'].toString()),
          position: LatLng(lat, lng),
          icon: customMarker, // 커스텀 마커 사용
          infoWindow: InfoWindow(
            title: '신호등 상태: $currentState',
            snippet: '남은 시간: $remainingTime초',
          ),
        );

        // 마커 업데이트 세트에 추가
        newMarkers.add(trafficMarker);

        // 신호등 데이터를 Map에 저장
        _trafficLightData[trafficLight['id'].toString()] = {
          'currentState': currentState,
          'remainingTime': remainingTime,
          'greenDuration': greenDuration,
          'redDuration': redDuration,
          'latitude': lat,
          'longitude': lng,
        };
      }

      // 마커를 업데이트하는 콜백 호출
      onMarkersUpdated(newMarkers);

      // 전역 타이머가 실행 중이지 않다면 타이머 시작
      if (_globalTimer == null || !_globalTimer!.isActive) {
        _startGlobalTimer(onMarkersUpdated);
      }
    } else {
      print('신호등 정보를 가져오지 못했습니다.');
    }
  }

  // 모든 신호등을 관리하는 전역 타이머 시작
  void _startGlobalTimer(Function(Set<Marker>) onMarkersUpdated) {
    print("타이머 시작");
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      Set<Marker> updatedMarkers = {};

      for (var trafficLightId in List.from(_trafficLightData.keys)) {
        var trafficLight = _trafficLightData[trafficLightId]!;

        String currentState = trafficLight['currentState'];
        int remainingTime = trafficLight['remainingTime'];
        int greenDuration = trafficLight['greenDuration'];
        int redDuration = trafficLight['redDuration'];
        double lat = trafficLight['latitude'];
        double lng = trafficLight['longitude'];

        if (remainingTime > 1) {
          remainingTime--; // 남은 시간 감소
        } else {
          // 시간이 0이 되면 상태 변경
          if (currentState == "RED") {
            currentState = "GREEN";
            remainingTime = greenDuration; // 녹색 신호 시간으로 재설정
          } else if (currentState == "GREEN") {
            currentState = "RED";
            remainingTime = redDuration; // 적색 신호 시간으로 재설정
          }
        }

        // 상태에 따른 색상 설정
        Color circleColor =
            currentState == "RED" ? AppColors.red : AppColors.green;

        // 커스텀 마커 생성 및 업데이트
        BitmapDescriptor customMarker =
            await createCircleMarker('$remainingTime', circleColor);

        Marker updatedMarker = Marker(
          markerId: MarkerId(trafficLightId),
          position: LatLng(lat, lng),
          icon: customMarker,
          infoWindow: InfoWindow(
            title: '신호등 상태: $currentState',
            snippet: '남은 시간: $remainingTime초',
          ),
        );

        // 업데이트된 마커 저장
        updatedMarkers.add(updatedMarker);

        // 업데이트된 데이터를 다시 Map에 저장
        _trafficLightData[trafficLightId] = {
          'currentState': currentState,
          'remainingTime': remainingTime,
          'greenDuration': greenDuration,
          'redDuration': redDuration,
          'latitude': lat,
          'longitude': lng,
        };
      }

      // 업데이트된 마커 콜백 호출
      onMarkersUpdated(updatedMarkers);
    });
  }

  // 타이머 중지 함수 (필요시 호출)
  void stopGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = null;
  }

  // 길안내
  // 신호등 ID로 신호등 정보를 받아와 지도에 표시하는 함수
  Future<void> addTrafficLightsByIdToMap({
    required List<dynamic> blinkerData,
    required Set<Marker> markers,
    required Function(Set<Marker>) onMarkersUpdated,
  }) async {
    Set<Marker> newMarkers = {};

    // 각 신호등에 대해 상태와 타이머를 관리하는 리스트
    List<Timer> timers = [];

    for (var trafficLight in blinkerData) {
      double lat = trafficLight['latitude'];
      double lng = trafficLight['longitude'];
      int greenDuration = trafficLight['greenDuration']; // 초록불 지속 시간 (초)
      int redDuration = trafficLight['redDuration']; // 빨간불 지속 시간 (초)
      int totalDuration = greenDuration + redDuration; // 총 주기 (초)
      String startTimeString =
          trafficLight['startTime']; // 초록불 시작 시간 (HH:mm:ss)
      // 현재 시간 가져오기
      // 초록불 시작 시간을 DateTime으로 변환
      // 1. 현재 시간과 초록불 시작 시간의 차이를 초 단위로 계산
      // 2. 경과한 시간을 총 주기로 나눈 나머지 구하기
      // 3. 나머지가 초록불 지속 시간보다 작으면 초록불, 크면 빨간불
      DateTime now = DateTime.now();
      DateTime startTime = DateFormat('HH:mm:ss').parse(startTimeString);
      startTime = DateTime(now.year, now.month, now.day, startTime.hour,
          startTime.minute, startTime.second);
      Duration difference = now.difference(startTime);
      int elapsedSeconds = difference.inSeconds; // 경과한 시간 (초 단위)
      int remainder = elapsedSeconds % totalDuration; // 주기를 초 단위로 나눈 나머지

      print('총 주기 $totalDuration, 빨강 $redDuration, 초록 $greenDuration');
      print('current time $now');
      print('green start time : $startTime');
      print('현재시간 초록시간 차를 초로 바꿈 : $elapsedSeconds');
      print('경과한 시간 나머지 $remainder');
      // 초기 상태 및 남은 시간 계산
      String currentState;
      int remainingTime;
      if (remainder < greenDuration) {
        currentState = "GREEN";
        remainingTime = greenDuration - remainder;
      } else {
        currentState = "RED";
        remainingTime = totalDuration - remainder;
      }

      // 상태에 따른 색상 설정
      Color circleColor =
          currentState == "RED" ? AppColors.red : AppColors.green;
      BitmapDescriptor customMarker =
          await createCircleMarker('$remainingTime', circleColor);

      // 마커 추가
      Marker trafficMarker = Marker(
        markerId: MarkerId(trafficLight['id'].toString()),
        position: LatLng(lat, lng),
        icon: customMarker,
        infoWindow: InfoWindow(
          title: '신호등 상태: $currentState',
          snippet: '남은 시간: $remainingTime초',
        ),
      );

      newMarkers.add(trafficMarker);

      // 타이머로 신호등 상태 업데이트
      Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          // 시간이 0이 되면 상태 전환
          if (currentState == "GREEN") {
            currentState = "RED";
            remainingTime = redDuration; // 빨간불 주기로 변경
          } else {
            currentState = "GREEN";
            remainingTime = greenDuration; // 초록불 주기로 변경
          }
        }

        // 상태에 따른 색상 설정
        circleColor = currentState == "RED" ? AppColors.red : AppColors.green;

        // 새로운 커스텀 마커 생성
        customMarker = await createCircleMarker('$remainingTime', circleColor);

        // 업데이트된 마커 생성
        Marker updatedMarker = Marker(
          markerId: trafficMarker.markerId,
          position: LatLng(lat, lng),
          icon: customMarker,
          infoWindow: InfoWindow(
            title: '신호등 상태: $currentState',
            snippet: '남은 시간: $remainingTime초',
          ),
        );

        // 업데이트된 마커 저장
        newMarkers.removeWhere(
            (marker) => marker.markerId == trafficMarker.markerId); // 기존 마커 제거
        newMarkers.add(updatedMarker); // 업데이트된 마커 추가

        // 마커 업데이트 콜백 호출
        onMarkersUpdated(newMarkers);
      });

      // 타이머를 리스트에 추가
      timers.add(timer);
    }

    // 마커를 업데이트하는 콜백 호출
    onMarkersUpdated(newMarkers);
  }

  Future<void> showCustomBottomSheet(
      BuildContext context, String currentState, int remainingTime) {
    return showModalBottomSheet(
      context: context, // 여기에서 context를 받아 사용
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('신호등 상태: $currentState'),
              Text('남은 시간: $remainingTime초'),
              ElevatedButton(
                onPressed: () {
                  print('Button clicked!');
                  Navigator.pop(context); // Bottom sheet 닫기
                },
                child: const Text('상세 정보 보기'),
              ),
            ],
          ),
        );
      },
    );
  }
}
