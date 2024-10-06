import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/destinationbar.dart';
import 'package:readygreen/widgets/map/routecard.dart';
import 'package:readygreen/widgets/map/routefinishmodal.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:provider/provider.dart';
import 'package:readygreen/provider/current_location.dart';
import 'package:readygreen/widgets/map/trafficlight.dart';

class MapDirectionPage extends StatefulWidget {
  final double? endLat; // 도착지 위도
  final double? endLng; // 도착지 경도
  final String? endPlaceName; // 도착지 이름

  const MapDirectionPage({
    super.key,
    this.endLat,
    this.endLng,
    this.endPlaceName,
  });

  @override
  _MapDirectionPageState createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final loc.Location _location = loc.Location();
  final Set<Marker> _markers = {};
  final List<LatLng> _routeCoordinates = []; // 경로 좌표 리스트
  final List<String> _routeDescriptions = []; // 추가된 부분: 경로 설명 리스트
  final Set<Circle> _circles = {}; // Circle들을 담을 Set 추가
  final TrafficLightService _trafficLightService =
      TrafficLightService(); // 신호등 서비스 추가
  Timer? _locationTimer; // 위치 업데이트 타이머
  Timer? _cameraIdleTimer; // 카메라가 멈춘 후 타이머 추가
  bool _isMapMoving = false; // 지도가 움직이는지 여부를 나타내는 변수
  int currentRouteIndex = 0; // 현재 경로 인덱스

  String? _destinationName; // 도착지 이름 저장할 변수
  String? _startLocationName; // 출발지 이름 저장할 변수
  bool _isRouteDetailVisible = true; // 경로 상세 정보 보이기 여부

  double? _totalDistance; // 전체 거리
  String? _totalTime; // 예상 시간
  List<LatLng> pointCoordinates = [];

// 유클리드 거리 계산
  double calculateDistance(LatLng currentPosition, LatLng point) {
    double dx = currentPosition.longitude - point.longitude;
    double dy = currentPosition.latitude - point.latitude;
    return sqrt(dx * dx + dy * dy) * 111000;
  }

// point 와 현재위치 거리 체크
  void _checkProximityToRoutePoints(LatLng currentLocation) {
    for (int i = currentRouteIndex; i < pointCoordinates.length; i++) {
      double distance = calculateDistance(currentLocation, pointCoordinates[i]);
      if (distance <= 10) {
        // 10 미터 이내로 가까워졌을 때
        _jumpToRouteDescription(i); // RouteCard를 해당 인덱스로 넘겨줌
        currentRouteIndex = i + 1; // 다음 포인트로 인덱스 업데이트
        break;
      }
    }
  }

  final PageController _pageController = PageController();

  void _jumpToRouteDescription(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

// 현재 위치와 도착지 간의 거리를 계산하여 도착지에 도착했을 때 모달을 띄움
  void _checkProximityToDestination(
      LatLng currentLocation, int type, Map<String, dynamic>? routeData) {
    double? destinationLat;
    double? destinationLng;

    // type에 따라 도착지 위도, 경도 다르게 처리
    if (type == 2) {
      destinationLat = widget.endLat;
      destinationLng = widget.endLng;
    } else if (routeData != null) {
      destinationLat = routeData['endlat'];
      destinationLng = routeData['endlng'];
    }

    if (destinationLat != null && destinationLng != null) {
      double distance = calculateDistance(
        currentLocation,
        LatLng(destinationLat, destinationLng),
      );
      print(
          '현재 위치: (${currentLocation.latitude}, ${currentLocation.longitude})');
      print('도착지 위치: ($destinationLat, $destinationLng)');
      print('계산된 거리: $distance 미터');
      if (distance <= 5) {
        // 도착지와의 거리가 5미터 이내일 때
        _showRouteFinishModal();
      }
    } else {
      print('도착지 정보가 없습니다.');
    }
  }

// 모달을 띄우는 함수
  void _showRouteFinishModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RouteFinishModal(
          onConfirm: _onFinishNavigation, // 길안내 종료 함수
          onCancel: () {
            Navigator.of(context).pop(); // 모달 닫기
          },
        );
      },
    );
  }

// 길안내 종료 요청 보내는 함수
  void _onFinishNavigation() async {
    MapStartAPI mapStartAPI = MapStartAPI();
    var result = await mapStartAPI.guideFinish(
      distance: _totalDistance ?? 0.0,
      startTime: _totalTime ?? '알 수 없음',
      watch: false,
    );

    if (result != null) {
      print("길안내 종료 성공");
      _cameraIdleTimer?.cancel(); // 페이지 종료 시 타이머 취소
      _stopLocationTimer(); // 위치 타이머도 확실히 종료
      super.dispose();
      handleBackNavigation(context); // 메인 화면으로 돌아가기
    } else {
      print("길안내 종료 실패");
    }

    Navigator.of(context).pop(); // 모달 닫기
  }

  // 지도 이동 시 타이머를 멈추고, 카메라가 멈춘 후 3초 뒤 타이머 재시작
  void _onCameraMove(CameraPosition position) {
    if (!_isMapMoving) {
      _stopLocationTimer(); // 타이머 중지
      _isMapMoving = true;
    } else {
      _isMapMoving = false;
    }

    _cameraIdleTimer?.cancel(); // 카메라가 멈출 때까지 이전 타이머 취소
  }

  void _onCameraIdle() {
    _cameraIdleTimer = Timer(const Duration(seconds: 2), () {
      _startLocationTimer(); // 2초 뒤 타이머 재시작
      _isMapMoving = false;
    });
  }

  @override
  void dispose() {
    _cameraIdleTimer?.cancel(); // 페이지 종료 시 타이머 취소
    _stopLocationTimer(); // 위치 타이머도 확실히 종료
    super.dispose();
  }

// 위치 정보를 업데이트하는 함수
  Future<void> _updateLocationAndCamera() async {
    loc.LocationData currentLocation = await _location.getLocation();

    final GoogleMapController controller = await _controller.future;

    double currentHeading = currentLocation.heading ?? 0.0;

    LatLng currentLatLng =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    // 카메라를 사용자 위치와 방향에 맞춰 업데이트
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 18.0,
        tilt: 0,
        bearing: currentHeading,
      ),
    ));
  }

  // 타이머 시작 함수에서 카메라 업데이트 추가
  void _startLocationTimer() {
    if (_locationTimer == null || !_locationTimer!.isActive) {
      _locationTimer =
          Timer.periodic(const Duration(seconds: 2), (Timer t) async {
        loc.LocationData currentLocation =
            await _location.getLocation(); // 위치 정보 가져오기
        _currentLocation();
        _updateLocationAndCamera(); // 위치 및 카메라 업데이트
        _checkProximityToRoutePoints(LatLng(
          currentLocation.latitude!, // 수정된 부분
          currentLocation.longitude!, // 수정된 부분
        )); // 새로운 함수 호출하여 경로 포인트 확인
      });
      print("위치 업데이트 타이머가 시작되었습니다.");
    }
  }

  // 타이머 종료 함수
  void _stopLocationTimer() {
    if (_locationTimer != null && _locationTimer!.isActive) {
      _locationTimer!.cancel();
      print("위치 업데이트 타이머가 종료되었습니다.");
    }
  }

  @override
  void initState() {
    super.initState();

    // 도착지 정보가 제대로 넘어왔는지 확인하기 위해 출력
    if (widget.endLat != null) {
      print(
          "도착지 위도: ${widget.endLat}, 경도: ${widget.endLng}, 이름: ${widget.endPlaceName}");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CurrentLocationProvider>(context, listen: false)
            .updateLocation();
        _fetchRouteData(); // 페이지가 로드될 때 API 호출
      });
    } else {
      print("도착지 정보가 없습니다. 다른 API 요청 실행.");
      _fetchDefaultRouteData();
    }
  }

  // 경로 요청을 위한 함수
  Future<void> _fetchRouteData() async {
    final locationProvider =
        Provider.of<CurrentLocationProvider>(context, listen: false);

    if (locationProvider.currentPosition != null) {
      // 현재 위치 정보
      double startX = locationProvider.currentPosition!.longitude;
      double startY = locationProvider.currentPosition!.latitude;
      String startName =
          locationProvider.currentPlaceName ?? 'Unknown Start Location';

      // 도착지 정보는 ArriveButton에서 전달받은 값 사용
      double? endX = widget.endLng;
      double? endY = widget.endLat;
      String? endName = widget.endPlaceName;

      // 요청 파라미터 출력
      print(
          "리퀘스트변수 - startX: $startX, startY: $startY, endX: $endX, endY: $endY, startName: $startName, endName: $endName");

      // API 호출
      MapStartAPI mapStartAPI = MapStartAPI();
      var routeData = await mapStartAPI.fetchRoute(
        startX: startX,
        startY: startY,
        endX: endX ?? 0.0,
        endY: endY ?? 0.0,
        startName: startName,
        endName: endName ?? '',
        watch: false,
      );

      // 응답 데이터 출력
      print('데이터 값~!~!~!~!~!~!~!~!~!: $routeData');
      if (routeData != null) {
        _processRouteData(routeData, 2); // 경로 데이터 처리
        _processBlinkerData(routeData['blinkerDTOs']); // 신호등 데이터 처리
        // 현재 위치와 도착지의 거리를 계산하고 모달을 띄우기 위해 호출
        _checkProximityToDestination(
          LatLng(locationProvider.currentPosition!.latitude,
              locationProvider.currentPosition!.longitude),
          2,
          routeData,
        );
      }
    } else {
      print("현재 위치를 찾을 수 없습니다.");
    }
  }

  // 신호등 데이터를 처리하고 신호등 마커를 지도에 추가하는 함수
  void _processBlinkerData(List<dynamic> blinkerData) {
    if (blinkerData.isNotEmpty) {
      // 신호등 ID 리스트 생성
      List<int> blinkerIds =
          blinkerData.map<int>((b) => b['id'] as int).toList();

      // 신호등을 지도에 추가
      _trafficLightService.addTrafficLightsByIdToMap(
        blinkerIds: blinkerIds,
        markers: _markers,
        onMarkersUpdated: (updatedMarkers) {
          if (mounted) {
            setState(() {
              _markers.addAll(updatedMarkers); // 업데이트된 신호등 마커 추가
            });
          }
        },
      );
    }
  }

  void _processRouteData(Map<String, dynamic>? routeData, int type) {
    if (routeData != null) {
      // 경로 데이터를 바탕으로 coordinates 및 description 처리
      List<dynamic> features = routeData['routeDTO']['features'];
      List<LatLng> coordinates = [];
      List<String> descriptions = []; // 추가된 부분: 경로 설명을 담을 리스트
      List<LatLng> pointCoordinates = [];

      for (var feature in features) {
        var geometry = feature['geometry'];

        // LineString 처리
        if (geometry['type'] == 'LineString') {
          List<dynamic> points = geometry['coordinates'];
          for (var point in points) {
            coordinates.add(LatLng(point[1], point[0])); // 경도, 위도 순서로 추가
          }
        }
        // Point 처리
        else if (geometry['type'] == 'Point') {
          var point = geometry['coordinates'];
          coordinates.add(LatLng(point[1], point[0])); // 경도, 위도 순서로 추가
          pointCoordinates.add(LatLng(point[1], point[0]));
          print('짜증작렬 ㅡㅡ .....');
          print(pointCoordinates);

          // 경로 설명을 리스트에 추가
          var description = feature['properties']['description'];
          descriptions.add(description); // 추가된 부분: description 저장

          // Point에 Circle 추가
          _circles.add(
            Circle(
              circleId: CircleId('point-${coordinates.length}'), // 고유 ID
              center: LatLng(point[1], point[0]), // 좌표 설정
              radius: 7, // 점의 크기
              fillColor: AppColors.green.withOpacity(0.3),
              strokeColor: AppColors.green,
              strokeWidth: 2,
            ),
          );
        }
      }

      setState(() {
        _routeCoordinates.addAll(coordinates);
        _routeDescriptions.addAll(descriptions); // 추가된 부분: 경로 설명 리스트 추가

        // 도착지에 마커 추가
        if (type == 2) {
          _markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(widget.endLat ?? 0.0, widget.endLng ?? 0.0),
              infoWindow: InfoWindow(title: widget.endPlaceName),
            ),
          );
        } else {
          _markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(
                  routeData['endlat'] ?? 0.0, routeData['endlng'] ?? 0.0),
              infoWindow: InfoWindow(title: widget.endPlaceName),
            ),
          );
        }
        // routeData에서 도착지 정보 가져오기
        _destinationName = routeData['destination'] ?? '장소 정보가 없습니다.';
        _startLocationName = routeData['origin'] ?? '현재위치';
        _totalDistance = routeData['distance'] ?? 0.0;
        _totalTime = routeData['time'] ?? '알 수 없음';

        print('거리와 시간!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        print("도착지 이름: $_destinationName");
        print("출발지 이름: $_startLocationName");
        print("총 거리: $_totalDistance");
        print("예상 시간: $_totalTime");
      });
    } else {
      print("No route data received.");
    }
  }

  Future<void> _fetchDefaultRouteData() async {
    // 다른 API 요청 처리
    print("기본 경로 데이터를 요청 중입니다...");

    MapStartAPI mapStartAPI = MapStartAPI();
    var routeData = await mapStartAPI.fetchGuideInfo();

    print('데이터 값~!~!~!~!~!~!~!~!~!: $routeData');
    _processRouteData(routeData, 1);
    if (routeData != null && routeData['blinkerDTOs'] != null) {
      _processBlinkerData(routeData['blinkerDTOs']); // 신호등 데이터를 처리하여 지도에 추가
    }

    print('$routeData[endlat]');
    print('$routeData[endlng]');
  }

  // 지도 생성 함수
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    // 사용자의 현재 위치로 카메라 이동
    _moveToCurrentLocation();
  }

  // 사용자의 현재 위치로 카메라를 이동시키는 함수
  Future<void> _moveToCurrentLocation() async {
    final locationProvider =
        Provider.of<CurrentLocationProvider>(context, listen: false);
    if (locationProvider.currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            locationProvider.currentPosition!.latitude,
            locationProvider.currentPosition!.longitude,
          ),
          zoom: 18.0, // 적절한 줌 레벨 설정
        ),
      ));
    }
  }

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation = await _location.getLocation();

    // 방향 정보를 가져옵니다.
    double currentHeading = currentLocation.heading ?? 0.0;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 18.0,
        tilt: 0, // 기본 기울기 설정
        bearing: currentHeading, // 방향에 맞춰 회전
      ),
    ));
  }

  void handleBackNavigation(BuildContext context) {
    if (Navigator.canPop(context)) {
      // 스택에 화면이 남아있으면 pop
      Navigator.pop(context);
    } else {
      // 스택이 비어 있으면 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final locationProvider = Provider.of<CurrentLocationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                // 초기 카메라 위치를 사용자 현재 위치로 설정
                locationProvider.currentPosition?.latitude ?? 36.3504119,
                locationProvider.currentPosition?.longitude ?? 127.3845475,
              ),
              zoom: 18.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            trafficEnabled: false, // 교통 정보 비활성화.
            markers: _markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routeCoordinates, // 경로 좌표 리스트
                color: AppColors.routegreen,
                width: 7,
                startCap: Cap.roundCap, // 시작 지점을 둥글게
                endCap: Cap.roundCap, // 끝 지점을 둥글게
              ),
            },
            circles: _circles, // Circle들을 지도에 표시
            onCameraMove: _onCameraMove, // 지도가 움직일 때 호출
            onCameraIdle: _onCameraIdle, // 지도가 멈췄을 때 호출
          ),
          Positioned(
            top: screenHeight * 0.8,
            right: screenWidth * 0.05,
            child: LocationButton(
              onTap: _currentLocation,
              screenWidth: screenWidth,
            ),
          ),
          Positioned(
            top: screenHeight * 0,
            left: screenWidth * 0,
            right: screenWidth * 0,
            child: DestinationBar(
              currentLocation: _startLocationName ??
                  locationProvider.currentPlaceName ??
                  '현재 위치',
              destination:
                  widget.endPlaceName ?? _destinationName ?? '', // 전달받은 도착지 이름
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.09, // 더 큰 높이 설정으로 아래 공간을 꽉 채움
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRouteDetailVisible =
                              !_isRouteDetailVisible; // 상세 경로 보기 토글
                        });
                        print("상세 경로 클릭");
                      },
                      child: Container(
                        color: AppColors.routegreen,
                        alignment: Alignment.center, // 가운데 정렬
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              "상세 경로",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // 안내 중지 클릭 처리
                        print("안내 중지 클릭");
                        MapStartAPI mapStartAPI = MapStartAPI();
                        bool result =
                            await mapStartAPI.guideDelete(isWatch: false);
                        if (result) {
                          _stopLocationTimer(); // 모든 타이머 종료
                          _cameraIdleTimer?.cancel(); // 카메라 타이머도 종료
                          print("안내가 중지되었습니다.");
                          handleBackNavigation(context);
                        } else {
                          print("안내 중지 실패");
                        }
                      },
                      child: Container(
                        color: AppColors.grey,
                        alignment: Alignment.center, // 가운데 정렬
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "안내 중지",
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 기존 코드
          if (_isRouteDetailVisible == true) // 상세 경로 보일 때
            Positioned(
              top: screenHeight * 0.18, // 카드 위치 조정
              left: screenWidth * 0.02,
              right: screenWidth * 0.02,
              child: RouteCard(
                routeDescriptions: _routeDescriptions,
                pageController: _pageController,
                onClose: () {
                  setState(() {
                    _isRouteDetailVisible = false; // 닫기 버튼 클릭 시 카드 닫기
                  });
                },
              ), // 경로 설명 카드 추가
            ),
        ],
      ),
    );
  }
}
