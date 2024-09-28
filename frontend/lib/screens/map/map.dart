import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart' as places;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geocoding/geocoding.dart';
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/draggable_favorites.dart';
import 'package:readygreen/widgets/map/speechsearch.dart';
import 'package:readygreen/widgets/map/placecard.dart';
import 'package:readygreen/screens/map/mapsearch.dart';
import 'package:readygreen/provider/current_location.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};

  String _selectedPlaceName = ''; // 선택된 장소 이름
  String _selectedAddress = ''; // 선택된 주소

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 위치 정보를 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrentLocationProvider>(context, listen: false)
          .updateLocation();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // 새로운 장소로 이동하고 마커 추가하는 함수
  void _goToPlace(
      double lat, double lng, String placeName, String address) async {
    final GoogleMapController controller = await _controller.future;

    // 지도 이동
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));

    // 마커 추가
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(placeName),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: placeName),
        ),
      );
      _selectedPlaceName = placeName; // 선택된 장소 이름 업데이트
      _selectedAddress = address; // 선택된 주소 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // 위치 정보가 업데이트될 때 Provider로부터 구독
    final locationProvider = Provider.of<CurrentLocationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Google Map 표시
          locationProvider.currentPosition == null
              ? const Center(child: CircularProgressIndicator()) // 위치 정보 로딩 중
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationProvider.currentPosition!.latitude,
                      locationProvider.currentPosition!.longitude,
                    ),
                    zoom: 17.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: _markers,
                  onTap: (LatLng tappedLocation) {
                    if (_markers.isNotEmpty) {
                      setState(() {
                        _markers.clear(); // 기존 마커 제거
                        _selectedPlaceName = ''; // 장소 이름 초기화
                        _selectedAddress = ''; // 주소 초기화
                      });
                    } else {
                      // 클릭한 위치에 마커 추가
                      _addMarkerWithPlaceName(tappedLocation);
                    }
                  },
                ),
          // Search bar
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: MapSearchBar(
              onSearchSubmitted: (query) {},
              onSearchChanged: (query) {}, // 검색창에서 입력 변화는 무시
              onTap: () async {
                // 검색창을 클릭하면 검색 페이지로 이동
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      onPlaceSelected: (lat, lng, placeName) {
                        _goToPlace(lat, lng, placeName, '주소 정보 없음');
                      },
                    ),
                  ),
                );

                // 검색 결과를 받아서 마커 표시
                if (result != null) {
                  _goToPlace(
                      result['lat'], result['lng'], result['name'], '주소 정보 없음');
                }
              },
            ),
          ),
          // 즐겨찾기 드래그 가능한 영역
          DraggableFavorites(
            scrollController: ScrollController(),
          ),

          // 위치 버튼
          Positioned(
            top: MediaQuery.of(context).size.height * 0.8,
            right: MediaQuery.of(context).size.width * 0.05,
            child: LocationButton(
              onTap: () {
                // 버튼 클릭 시 위치 정보를 다시 업데이트
                locationProvider.updateLocation();
              },
              screenWidth: MediaQuery.of(context).size.width,
            ),
          ),
          // 하단에 PlaceCard 추가 (위치 정보 표시)
          if (_selectedPlaceName.isNotEmpty && _selectedAddress.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: PlaceCard(
                  placeName: _selectedPlaceName,
                  address: _selectedAddress,
                  onTap: () {
                    print('PlaceCard clicked: $_selectedPlaceName');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 지도를 클릭할 때 Google Places API로 장소 이름 가져오기
  Future<void> _addMarkerWithPlaceName(LatLng tappedLocation) async {
    final places.GoogleMapsPlaces placesApi = places.GoogleMapsPlaces(
        apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
    final response = await placesApi.searchByText(
      '${tappedLocation.latitude},${tappedLocation.longitude}',
      language: 'ko',
    );

    if (response.isOkay && response.results.isNotEmpty) {
      final placeName = response.results.first.name; // 장소 이름 가져오기
      final address =
          response.results.first.formattedAddress ?? '주소 정보 없음'; // 주소 가져오기

      setState(() {
        _markers.clear(); // 기존 마커 제거
        _markers.add(
          Marker(
            markerId: MarkerId(tappedLocation.toString()),
            position: tappedLocation,
            infoWindow: InfoWindow(
              title: placeName, // 장소 이름을 표시
            ),
          ),
        );
        _selectedPlaceName = placeName; // 선택된 장소 이름 업데이트
        _selectedAddress = address; // 선택된 주소 업데이트
      });
    } else {
      print('장소 이름을 가져오지 못했습니다.');
    }
  }
}
