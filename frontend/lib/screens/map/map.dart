import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:readygreen/bottom_navigation.dart';
import 'package:readygreen/widgets/map/search.dart';

void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(36.354946759143, 127.29980994578);
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Location _location = Location();

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = Location();

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = LocationData.fromMap({
        'latitude': _center.latitude,
        'longitude': _center.longitude,
      });
    }

    // 현재 위치로 카메라 이동
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 16.0,
      ),
    ));
  }

  // SearchBar의 검색 결과 제출 함수
  void _onSearchSubmitted(String query) {
    // 여기에 검색 결과를 처리하는 로직을 작성할거임 ..
  }

  // 음성 검색 기능을 처리하는 함수
  void _onVoiceSearch() {
    // 음성 검색 로직을 여기에 작성할거임 ..
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Google Map
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
            ),
            // Search bar
            Positioned(
              top: 30,
              left: 25,
              right: 25,
              child: MapSearchBar(
                onSearchSubmitted: _onSearchSubmitted,
                onVoiceSearch: _onVoiceSearch,
              ),
            ),
            // 위치버튼
            Positioned(
              top: 620,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _currentLocation();
                },
                child: Container(
                  width: screenWidth * (40 / 360),
                  height: screenWidth * (40 / 360),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * (6 / 360)),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ),
            ),
            // DraggableScrollableSheet(즐겨찾기 드래그)
            DraggableScrollableSheet(
              initialChildSize: 0.04,
              minChildSize: 0.04, // 최소 높이
              maxChildSize: 0.85, // 최대 높이
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 드래그 인디케이터
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 즐겨찾기 목록
                      Expanded(
                        child: ListView(
                          controller: scrollController, // 리스트가 스크롤 가능하도록 설정
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                '자주 가는 목적지',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              // 임시로 데이터 입력해서 출력함
                              leading: Icon(Icons.business),
                              title: Text('삼성화재 유성 연수원'),
                              subtitle: Text('대전 유성구 동서대로 98-39'),
                              trailing: ElevatedButton(
                                onPressed: null, // 길찾기 기능 추가 가능
                                child: Text('길찾기'),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_pin),
                              title: Text('멀티캠퍼스 역삼'),
                              subtitle: Text('서울 강남구 테헤란로 212'),
                              trailing: ElevatedButton(
                                onPressed: null,
                                child: Text('길찾기'),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.home),
                              title: Text('어쩌구저쩌구 아파트'),
                              subtitle: Text('대전광역시 어쩌구동 어쩌구'),
                              trailing: ElevatedButton(
                                onPressed: null,
                                child: Text('길찾기'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
