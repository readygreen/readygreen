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
  painter.paint(
      canvas, Offset(size.width * 0.2, size.height * 0.25)); // 텍스트 위치 조정

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
  Future<void> addTrafficLightsToMap(
      {required double latitude,
      required double longitude,
      required Set<Marker> markers,
      required Function(Set<Marker>) onMarkersUpdated}) async {
    const int radius = 700; // 반경 700미터

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

        // 상태에 따른 색상 설정
        Color circleColor;
        if (currentState == "RED") {
          circleColor = AppColors.red;
        } else if (currentState == "GREEN") {
          circleColor = AppColors.green;
        } else {
          circleColor = AppColors.grey; // 상태가 없을 때 회색
        }
        print(
            '신호등 ${trafficLight['id']} 남은 시간: $remainingTime초, 상태: $currentState');
        // 커스텀 마커 생성
        BitmapDescriptor customMarker =
            await createCircleMarker('$remainingTime', circleColor);

        // 마커 추가
        newMarkers.add(
          Marker(
            markerId: MarkerId(trafficLight['id'].toString()),
            position: LatLng(lat, lng),
            icon: customMarker, // 커스텀 마커 사용
            infoWindow: InfoWindow(
              title: '신호등 상태: $currentState',
              snippet: '남은 시간: $remainingTime초',
            ),
          ),
        );
      }

      // 마커를 업데이트하는 콜백 호출
      onMarkersUpdated(newMarkers);
    } else {
      print('신호등 정보를 가져오지 못했습니다.');
    }
  }
}
