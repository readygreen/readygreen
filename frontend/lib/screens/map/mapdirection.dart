import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/destinationbar.dart';
import 'package:readygreen/widgets/map/routecard.dart';
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

  String? _destinationName; // 도착지 이름 저장할 변수
  bool _isRouteDetailVisible = false; // 경로 상세 정보 보이기 여부

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

          // 경로 설명을 리스트에 추가
          var description = feature['properties']['description'];
          descriptions.add(description); // 추가된 부분: description 저장

          // Point에 Circle 추가
          _circles.add(
            Circle(
              circleId: CircleId('point-${coordinates.length}'), // 고유 ID
              center: LatLng(point[1], point[0]), // 좌표 설정
              radius: 7, // 점의 크기
              fillColor: AppColors.green.withOpacity(0.3), // 파란색 점
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
          zoom: 17.0, // 적절한 줌 레벨 설정
        ),
      ));
    }
  }

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation = await _location.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 17.0,
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
                locationProvider.currentPosition?.latitude ?? 0.0,
                locationProvider.currentPosition?.longitude ?? 0.0,
              ),
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
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
              currentLocation: locationProvider.currentPlaceName ?? '',
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
          if (_isRouteDetailVisible) // 상세 경로 보일 때
            Positioned(
              top: screenHeight * 0.18, // 카드 위치 조정
              left: screenWidth * 0.02,
              right: screenWidth * 0.02,
              child: RouteCard(
                routeDescriptions: _routeDescriptions,
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
