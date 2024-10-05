import 'dart:async';
import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart' as places;
import 'package:geocoding/geocoding.dart';
import 'package:readygreen/screens/map/mapdirection.dart';
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/draggable_favorites.dart';
import 'package:readygreen/widgets/map/placecard.dart';
import 'package:readygreen/widgets/map/trafficlight.dart'; // trafficlight.dart 추가
import 'package:readygreen/screens/map/mapsearch.dart';
import 'package:readygreen/provider/current_location.dart';
import 'package:provider/provider.dart';
import 'package:readygreen/api/map_api.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}
class BookmarkDTO {
  final int id;
  final String name;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String? alertTime;
  final String placeId;

  BookmarkDTO({
    required this.id,
    required this.name,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    this.alertTime,
    required this.placeId,
  });
}

class _MapPageState extends State<MapPage> {
  final MapStartAPI mapStartAPI = MapStartAPI();
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _placeMarkers = {}; // 장소 선택 마커
  final Set<Marker> _trafficLightMarkers = {}; // 신호등 마커
  final TrafficLightService _trafficLightService =
      TrafficLightService(); // 신호등 서비스 추가

  String _placeId = '';
  String _selectedPlaceName = ''; // 선택된 장소 이름
  String _selectedAddress = ''; // 선택된 주소
  double _selectedLat = 0.0; // 선택된 위도
  double _selectedLng = 0.0; // 선택된 경도
  List<BookmarkDTO> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _checkIsGuide();
    _fetchBookmarks();
    // 앱 시작 시 위치 정보를 업데이트하고 신호등 정보를 한 번만 요청
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider =
          Provider.of<CurrentLocationProvider>(context, listen: false);
      await locationProvider.updateLocation();
      // 신호등 정보 요청
      _updateTrafficLights(locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude);
    });
  }

  Future<void> _fetchBookmarks() async {
    final bookmarksData = await mapStartAPI.fetchBookmarks();

    if (bookmarksData != null) {
      // 북마크 데이터를 BookmarkDTO 리스트로 변환
      List<BookmarkDTO> fetchedBookmarks = bookmarksData.map<BookmarkDTO>((bookmark) {
        return BookmarkDTO(
          id: bookmark['id'],
          name: bookmark['name'],
          destinationName: bookmark['destinationName'],
          latitude: bookmark['latitude'],
          longitude: bookmark['longitude'],
          placeId: bookmark['placeId'],
        );
      }).toList();

      // 변환한 데이터를 상태에 저장
      setState(() {
        _bookmarks = fetchedBookmarks;
      });
    } else {
      print('북마크 데이터를 불러오지 못했습니다.');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _checkIsGuide() async {
    if (await mapStartAPI.checkIsGuide()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapDirectionPage()),
      );
    }
  }

  // 신호등 정보를 업데이트하는 함수
  Future<void> _updateTrafficLights(double latitude, double longitude) async {
    await _trafficLightService.addTrafficLightsToMap(
      latitude: latitude,
      longitude: longitude,
      markers: _trafficLightMarkers,
      onMarkersUpdated: (newMarkers) {
        if (mounted) {
          setState(() {
            _trafficLightMarkers.addAll(newMarkers); // 기존 신호등 마커 업데이트
          });
        }
      },
    );
  }
  bool _isPlaceBookmarked(String placeId) {
    
    return _bookmarks.any((bookmark) => bookmark.placeId == placeId);
  }
  // 새로운 장소로 이동하고 장소 선택 마커 추가하는 함수
  void _goToPlace(
      double lat, double lng, String placeName, String placeId, String address) async {
    final GoogleMapController controller = await _controller.future;

    // 지도 이동
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));

    // 장소 선택 마커 추가
    setState(() {
      _placeMarkers.clear(); // 이전 장소 선택 마커 제거 (항상 1개 유지)
      _placeMarkers.add(
        Marker(
          markerId: MarkerId(placeName),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: placeName),
        ),
      );
      _placeId = 
      _selectedPlaceName = placeName; // 선택된 장소 이름 업데이트
      _selectedAddress = address; // 선택된 주소 업데이트
      _selectedLat = lat; // 선택된 위도 업데이트
      _selectedLng = lng; // 선택된 경도 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // 위치 정보가 업데이트될 때 Provider로부터 구독
    final locationProvider = Provider.of<CurrentLocationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  markers: _trafficLightMarkers
                      .union(_placeMarkers), // 신호등 마커와 장소 마커 모두 표시
                  onTap: (LatLng tappedLocation) {
                    setState(() {
                      if (_placeMarkers.isNotEmpty) {
                        // 장소 선택 마커가 있을 경우 마커를 제거
                        _placeMarkers.clear();
                        _selectedPlaceName = ''; // PlaceCard 숨김
                        _selectedAddress = '';
                      } else {
                        // 장소 선택 마커가 없을 경우 장소 마커 추가
                        _addMarkerWithPlaceName(tappedLocation);
                      }
                    });
                  },
                ),
          // Search bar
          Positioned(
            top: MediaQuery.of(context).size.height * 0.06,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06,
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
                        _goToPlace(lat, lng, placeName,_placeId, '주소 정보 없음');
                      },
                    ),
                  ),
                );

                // 검색 결과를 받아서 장소 선택 마커 표시
                if (result != null) {
                  _goToPlace(
                      result['lat'], result['lng'], result['name'],_placeId, '주소 정보 없음');
                }
              },
            ),
          ),
          // 즐겨찾기 드래그 가능한 영역 추가
          DraggableFavorites(
            scrollController: ScrollController(),
          ),

          // 위치 버튼
          Positioned(
            top: MediaQuery.of(context).size.height * 0.8,
            right: MediaQuery.of(context).size.width * 0.05,
            child: LocationButton(
              onTap: () async {
                // 버튼 클릭 시 위치 정보를 다시 업데이트
                locationProvider.updateLocation();

                // 위치가 null이 아니면 카메라를 현재 위치로 이동
                if (locationProvider.currentPosition != null) {
                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        locationProvider.currentPosition!.latitude,
                        locationProvider.currentPosition!.longitude,
                      ),
                    ),
                  );

                  // 신호등 정보 요청
                  _updateTrafficLights(
                    locationProvider.currentPosition!.latitude,
                    locationProvider.currentPosition!.longitude,
                  );
                }
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
                  lat: _selectedLat, // 선택된 위도 전달
                  lng: _selectedLng, // 선택된 경도 전달
                  placeId: _placeId,
                  onTap: () {
                    print('PlaceCard clicked: $_selectedPlaceName');
                    print('위도: $_selectedLat, 경도: $_selectedLng');
                  },
                  checked: _isPlaceBookmarked(_placeId),
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
      final placeId = response.results.first.placeId;

      print('선택된 장소 이름: $placeName');
      print('선택된 주소: $address');
      print('위도: ${tappedLocation.latitude}, 경도: ${tappedLocation.longitude}');

      setState(() {
        _placeMarkers.clear(); // 기존 장소 마커 제거
        _placeMarkers.add(
          Marker(
            markerId: MarkerId(tappedLocation.toString()),
            position: tappedLocation,
            infoWindow: InfoWindow(
              title: placeName, // 장소 이름을 표시
            ),
          ),
        );
        _placeId = placeId;
        _selectedPlaceName = placeName; // 선택된 장소 이름 업데이트
        _selectedAddress = address; // 선택된 주소 업데이트
        _selectedLat = tappedLocation.latitude; // 선택된 위도 업데이트
        _selectedLng = tappedLocation.longitude; // 선택된 경도 업데이트
      });

      // 신호등 정보 요청 및 마커 추가
      _updateTrafficLights(_selectedLat, _selectedLng);
    } else {
      print('장소 이름을 가져오지 못했습니다.');
    }
  }
}
