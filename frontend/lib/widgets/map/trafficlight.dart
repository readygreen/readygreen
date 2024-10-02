import 'dart:async'; // Timer 클래스 사용을 위해 추가
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/map_api.dart';

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

  // 신호등 정보를 받아와 마커로 지도에 표시하는 함수
  Future<void> addTrafficLightsToMap({
    required double latitude,
    required double longitude,
    required Set<Marker> markers,
    required Function(Set<Marker>) onMarkersUpdated,
  }) async {
    const int radius = 500; // 반경 500미터

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

        // 타이머 시작 (남은 시간 카운트다운)
        _startCountdown(
          trafficLightId: trafficLight['id'].toString(),
          currentState: currentState,
          remainingTime: remainingTime,
          greenDuration: greenDuration,
          redDuration: redDuration,
          latitude: lat,
          longitude: lng,
          onStateChanged: (newMarker) {
            newMarkers.add(newMarker); // 상태가 변경된 마커 추가
            onMarkersUpdated(newMarkers); // 업데이트된 마커 전달
          },
        );
      }

      // 마커를 업데이트하는 콜백 호출
      onMarkersUpdated(newMarkers);
    } else {
      print('신호등 정보를 가져오지 못했습니다.');
    }
  }

  // 신호등별로 개별 타이머로 남은 시간 관리
  void _startCountdown({
    required String trafficLightId,
    required String currentState,
    required int remainingTime,
    required int greenDuration,
    required int redDuration,
    required double latitude,
    required double longitude,
    required Function(Marker) onStateChanged,
  }) {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 1) {
        remainingTime--; // 1초마다 감소

        // 숫자가 매초 감소할 때마다 마커 업데이트
        Color circleColor =
            currentState == "RED" ? AppColors.red : AppColors.green;
        BitmapDescriptor newCustomMarker =
            await createCircleMarker('$remainingTime', circleColor);

        // 마커 업데이트
        Marker updatedMarker = Marker(
          markerId: MarkerId(trafficLightId),
          position: LatLng(latitude, longitude),
          icon: newCustomMarker,
          infoWindow: InfoWindow(
            title: '신호등 상태: $currentState',
            snippet: '남은 시간: $remainingTime초',
          ),
        );

        onStateChanged(updatedMarker); // 매초 마커 상태 변경 콜백
      } else {
        // 남은 시간이 0이 되었을 때 상태 변경
        if (currentState == "RED") {
          currentState = "GREEN";
          remainingTime = greenDuration; // greenDuration으로 재설정
        } else if (currentState == "GREEN") {
          currentState = "RED";
          remainingTime = redDuration; // redDuration으로 재설정
        }

        // 상태 변경 시 마커 색상 및 숫자 업데이트
        Color newCircleColor =
            currentState == "RED" ? AppColors.red : AppColors.green;
        BitmapDescriptor newCustomMarker =
            await createCircleMarker('$remainingTime', newCircleColor);

        // 마커 업데이트
        Marker updatedMarker = Marker(
          markerId: MarkerId(trafficLightId),
          position: LatLng(latitude, longitude),
          icon: newCustomMarker,
          infoWindow: InfoWindow(
            title: '신호등 상태: $currentState',
            snippet: '남은 시간: $remainingTime초',
          ),
        );

        onStateChanged(updatedMarker); // 마커 상태 변경 콜백
      }
    });
  }
}
