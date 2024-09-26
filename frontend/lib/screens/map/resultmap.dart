import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readygreen/widgets/map/mapsearchbackbar.dart';
import 'package:readygreen/screens/map/mapsearch.dart';

class ResultMapPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String placeName;
  final String searchQuery;

  const ResultMapPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.searchQuery,
  });

  @override
  _ResultMapPageState createState() => _ResultMapPageState();
}

class _ResultMapPageState extends State<ResultMapPage> {
  late GoogleMapController mapController;
  late LatLng _center;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.lat, widget.lng); // 초기 중심 좌표를 전달받은 값으로 설정
    _addMarker(widget.lat, widget.lng, widget.placeName); // 장소 마커 추가
  }

  // 장소 마커를 추가하는 함수
  void _addMarker(double lat, double lng, String placeName) async {
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

  Future<void> _goToPlace(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _goToPlace(widget.lat, widget.lng); // 전달받은 위치로 카메라 이동
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
            markers: _markers,
          ),
          // 검색 바 배치
          Positioned(
            top: screenHeight * 0.04,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: MapSearchBackBar(
              placeName: widget.searchQuery, // 검색한 장소 이름을 표시
              onSearchSubmitted: (value) {
                print("검색 제출됨: $value");
              },
              onVoiceSearch: () {
                print("음성 검색 실행");
              },
              onSearchChanged: (value) {
                print("검색어 변경됨: $value");
              },
              onTap: () async {
                // 검색 바 클릭 시 MapSearchPage로 이동
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      onPlaceSelected: (lat, lng, placeName) {
                        // 장소가 선택되면 해당 장소로 이동하고 마커 표시
                        _goToPlace(lat, lng);
                        _addMarker(lat, lng, placeName);
                      },
                    ),
                  ),
                );

                // 검색 완료 후 페이지로 돌아오면 결과 처리
                if (result != null) {
                  _goToPlace(result['lat'], result['lng']);
                  _addMarker(result['lat'], result['lng'], result['name']);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
