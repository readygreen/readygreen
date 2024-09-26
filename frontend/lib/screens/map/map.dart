import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/draggable_favorites.dart';
import 'package:readygreen/widgets/map/speechsearch.dart';
import 'package:readygreen/screens/map/mapsearch.dart';
import 'package:google_maps_webservice/places.dart' as places;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(36.354946759143, 127.29980994578); // 임시좌표
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final loc.Location _location = loc.Location();

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation(); // 앱 실행 시 사용자 위치 받아오기
  }

  // 사용자의 현재 위치를 받아와서 지도 중심을 설정하는 함수
  Future<void> _initializeCurrentLocation() async {
    try {
      loc.LocationData currentLocation = await _location.getLocation();

      setState(() {
        // 사용자의 현재 위치로 중심 좌표 설정
        _center = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });

      // 카메라를 현재 위치로 이동
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _center,
          zoom: 17.0,
        ),
      ));
    } catch (e) {
      print('현재 위치를 가져오는 데 실패했습니다: $e');
    }
  }

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation;
    var location = loc.Location();

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = loc.LocationData.fromMap({
        'latitude': _center.latitude,
        'longitude': _center.longitude,
      });
    }

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 17.0,
      ),
    ));
  }

  // 새로운 장소로 이동하고 마커 추가하는 함수
  void _goToPlace(double lat, double lng, String placeName) async {
    final GoogleMapController controller = await _controller.future;

    // 지도 이동
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));

    // 마커 추가
    setState(() {
      _markers.clear(); // 기존 마커 제거
      _markers.add(
        Marker(
          markerId: MarkerId(placeName),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: placeName),
        ),
      );
    });
  }

  // 지도를 클릭할 때 마커를 추가하고, 역지오코딩을 통해 주소를 가져오는 함수
  Future<void> _addMarkerWithAddress(LatLng tappedLocation) async {
    // 좌표를 주소로 변환 (역지오코딩)
    List<Placemark> placemarks = await placemarkFromCoordinates(
      tappedLocation.latitude,
      tappedLocation.longitude,
    );

    String address = placemarks.isNotEmpty
        ? '${placemarks.first.street}, ${placemarks.first.locality}'
        : '알 수 없는 위치';

    // 마커 추가
    setState(() {
      // 기존 마커가 이미 있으면 제거
      if (_markers.isNotEmpty) {
        _markers.clear();
      } else {
        // 새로운 마커 추가
        _markers.add(
          Marker(
            markerId: MarkerId(tappedLocation.toString()),
            position: tappedLocation,
            infoWindow: InfoWindow(
              title: address,
            ),
          ),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _markers,

            // 지도 클릭 시 마커 추가 및 주소 표시
            onTap: (LatLng tappedLocation) {
              _addMarkerWithAddress(tappedLocation); // 클릭한 위치에 마커 추가
            },
          ),
          // Search bar
          Positioned(
            top: screenHeight * 0.04,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: MapSearchBar(
              onSearchSubmitted: (query) {},
              onSearchChanged: (query) {}, // 검색창에서 입력 변화는 무시
              onTap: () async {
                // 검색창을 클릭하면 검색 페이지로 이동
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      onPlaceSelected: _goToPlace,
                    ),
                  ),
                );

                // 검색 결과를 받아서 마커 표시
                if (result != null) {
                  _goToPlace(result['lat'], result['lng'], result['name']);
                }
              },
            ),
          ),
          // 위치 버튼
          Positioned(
            top: screenHeight * 0.8,
            right: screenWidth * 0.05,
            child: LocationButton(
              onTap: _currentLocation,
              screenWidth: screenWidth,
            ),
          ),
          // 즐겨찾기 드래그 가능한 영역
          DraggableFavorites(
            scrollController: ScrollController(),
          ),
        ],
      ),
    );
  }
}
