import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:readygreen/bottom_navigation.dart';
import 'package:readygreen/widgets/map/search.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/draggable_favorites.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:readygreen/widgets/map/speechsearch.dart';

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

  final Location _location = Location();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _voiceInput = '';

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
      print("Speech recognition not available");
    }
  }

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
        zoom: 17.0,
      ),
    ));
  }

  // SearchBar의 검색 결과 제출 함수
  void _onSearchSubmitted(String query) {
    // 여기에 검색 결과를 처리하는 로직을 작성할거임 ..
    print('검색어: $query');
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
        // 음성 검색 중 UI 표시
        SpeechSearchDialog.show(context, _voiceInput, 'assets/images/mic.png');

        // 타임아웃 설정 (5초 후 강제로 종료 일단 안꺼져서 임시로 ㅜㅜ ..)
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
            _onSearchSubmitted(_voiceInput); // 음성 입력을 검색에 사용
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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            child: LocationButton(
              onTap: _currentLocation,
              screenWidth: screenWidth,
            ),
          ),
          // DraggableScrollableSheet(즐겨찾기 드래그)
          DraggableFavorites(
            scrollController: ScrollController(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
