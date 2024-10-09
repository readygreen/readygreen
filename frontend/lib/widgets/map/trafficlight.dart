import 'dart:async';
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
  Timer? _globalTimer; // 하나의 전역 타이머
  final Map<String, Map<String, dynamic>> _trafficLightData =
      {}; // 신호등 데이터를 저장하는 Map

  // 신호등 정보를 받아와 마커로 지도에 표시하는 함수
  Future<void> addTrafficLightsToMap({
    required BuildContext context,
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
          // infoWindow: InfoWindow(
          //   title: '신호등 상태: $currentState',
          //   snippet: '남은 시간: $remainingTime초',
          // ),
          onTap: () {
            // 마커 클릭 시 모달 띄우기
            print("마커 클릭해서 뜸");
            _showTrafficLightModal(context, trafficLight['id']);
          },
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
        _startGlobalTimer(context, onMarkersUpdated);
      }
    } else {
      print('신호등 정보를 가져오지 못했습니다.');
    }
  }

  // 모든 신호등을 관리하는 전역 타이머 시작
  void _startGlobalTimer(BuildContext context,Function(Set<Marker>) onMarkersUpdated) {
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
          // infoWindow: InfoWindow(
          //   title: '신호등 상태: $currentState',
          //   snippet: '남은 시간: $remainingTime초11',
          // ),
          onTap: () {
            // 마커 클릭 시 모달 띄우기
            print("마커 클릭해서 창 뜸");
            print(trafficLightId);
            _showTrafficLightModal(context, trafficLightId);
          },
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

  // 신호등 ID로 신호등 정보를 받아와 지도에 표시하는 함수
  Future<void> addTrafficLightsByIdToMap({
    required List<int> blinkerIds,
    required Set<Marker> markers,
    required Function(Set<Marker>) onMarkersUpdated,
  }) async {
    // 신호등 정보 요청 (ID로)
    final List<dynamic>? trafficLightData =
        await api.fetchBlinkerInfoByIds(blinkerIds: blinkerIds);

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
            snippet: '남은 시간: $remainingTime초22',
          ),
        );

        // 마커 업데이트 세트에 추가
        newMarkers.add(trafficMarker);
      }

      // 마커를 업데이트하는 콜백 호출
      onMarkersUpdated(newMarkers);
    } else {
      print('신호등 정보를 가져오지 못했습니다.');
    }
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
// 모달을 띄우는 함수
  void _showTrafficLightModal(BuildContext context, String trafficLightId) {
    final TextEditingController blueTimeController = TextEditingController();
    final TextEditingController redTimeController = TextEditingController();
    final TextEditingController secondBlueTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '신호등 ID: $trafficLightId',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '파란불 시각을 입력하세요 (hhmmss)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: blueTimeController,
                    decoration: const InputDecoration(
                      labelText: '파란불 시각',
                      hintText: 'hhmmss',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '빨간불 시각을 입력하세요 (hhmmss)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: redTimeController,
                    decoration: const InputDecoration(
                      labelText: '빨간불 시각',
                      hintText: 'hhmmss',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '두번째 파란불 시각을 입력하세요 (hhmmss)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: secondBlueTimeController,
                    decoration: const InputDecoration(
                      labelText: '두번째 파란불 시각',
                      hintText: 'hhmmss',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          // 입력된 값 가져오기
                          String blueTime = blueTimeController.text;
                          String redTime = redTimeController.text;
                          String secondBlueTime = secondBlueTimeController.text;

                          // 입력값을 사용하여 API 호출
                          bool success = await api.updateBlinkerWithTimes(
                            id: trafficLightId,
                            startTime: blueTime,
                            middleTime: redTime,
                            endTime: secondBlueTime,
                          );

                          // 제보 성공 시 성공 모달 띄우기
                          if (success) {
                            Navigator.pop(context);
                            _showSuccessModal(context);
                          }else{
                            Navigator.pop(context);
                          }

                          // 모달 닫기
                        },
                        child: const Text('제보하기', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // 모달 닫기
                        },
                        child: const Text('닫기', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 성공 모달을 보여주는 함수
  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  '성공!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '포인트 300점을 얻었습니다!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 성공 모달 닫기
                  },
                  child: const Text('확인', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
