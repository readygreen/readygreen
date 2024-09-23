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
  final LatLng _center = const LatLng(36.354946759143, 127.29980994578);
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final loc.Location _location = loc.Location();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _voiceInput = '';

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // SpeechToText 초기화
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech!.initialize();
    if (!available) {
      print("음성인식 초기화 실패");
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

  // 음성 인식 기능을 처리하는 함수
  void _onVoiceSearch() async {
    if (_speech == null) {
      print("Speech recognition not initialized");
      return;
    }

    if (!_isListening) {
      bool available = await _speech!.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        SpeechSearchDialog.show(context, _voiceInput, 'assets/images/mic.png');

        // 타임아웃 설정 (5초 후 강제로 종료)
        Future.delayed(const Duration(seconds: 5), () {
          if (_isListening) {
            _speech!.stop();
            setState(() => _isListening = false);
            SpeechSearchDialog.hide(context);
            print('타임아웃으로 음성 인식 종료');
          }
        });

        _speech!.listen(
          onResult: (val) => setState(() {
            _voiceInput = val.recognizedWords;
            print('음성 인식 결과: $_voiceInput');
            SpeechSearchDialog.hide(context); // 음성 인식 완료 시 다이얼로그 닫기
          }),
        );
      } else {
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech!.stop();
      SpeechSearchDialog.hide(context); // 음성 검색 중 UI 닫기
    }
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
              onSearchSubmitted: (query) {
                // 검색창에서 검색 버튼 클릭 시에도 검색 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      onPlaceSelected: _goToPlace, // 장소 선택 시 함수 전달
                    ),
                  ),
                );
              },
              onVoiceSearch: _onVoiceSearch, // 음성 검색 기능은 유지
              onSearchChanged: (query) {}, // 검색창에서 입력 변화는 무시
              onTap: () {
                // 검색창을 클릭하면 검색 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      onPlaceSelected: _goToPlace, // 장소 선택 시 함수 전달
                    ),
                  ),
                );
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
