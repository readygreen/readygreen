import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/widgets/map/map_autocomplete.dart';
import 'package:readygreen/widgets/map/search.dart';
import 'package:readygreen/widgets/map/locationbutton.dart';
import 'package:readygreen/widgets/map/draggable_favorites.dart';
import 'package:readygreen/widgets/map/speechsearch.dart';
import 'package:readygreen/screens/map/mapsearchresult.dart';

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

  final loc.Location _location = loc.Location(); // loc.Location으로 변경
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _voiceInput = '';

  final Set<Marker> _markers = {}; // 마커 목록 추가

  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDwyviOI57Suh4mCp_ncISKBbloI5eIayo');
  //apikey 나중에 숨겨놔야함 ..

  List<Prediction> _autoCompleteResults = []; // 자동완성 결과 저장

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
      print("음성인식 X");
    }
  }

  // 위치 정보를 받아오는 함수
  Future<void> _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    loc.LocationData currentLocation;
    var location = loc.Location(); // loc.Location으로 변경

    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = loc.LocationData.fromMap({
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

  // 자동완성 결과를 가져오는 함수
  Future<void> _getAutoCompleteResults(String query) async {
    if (query.isEmpty) return;

    loc.LocationData currentLocation = await _location.getLocation();

    // Google Places API로 자동완성 요청
    final response = await places.autocomplete(
      query,
      location: Location(
          lat: currentLocation.latitude!, lng: currentLocation.longitude!),
      radius: 5000,
      // 5km 반경 내의 결과를 필터링 해주는데 .... 반경을 지정해주는게 낫나 ? 모든 결과를 하면 자꾸 미국이 나와 ㅋㅋ...;;
      // 우리는 뚜벅이들을 위한거니까 반경을 정해주는것도 괜찮은것같은데 필터링 안먹히는듯 ..;;?
      language: 'ko',
    );

    if (response.isOkay) {
      setState(() {
        _autoCompleteResults = response.predictions;
      });
    } else {
      print('자동완성 실패: ${response.errorMessage}');
    }
  }

  // SearchBar의 검색 결과 제출 함수
  void _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    // Google Places API로 검색
    final response = await places.searchByText(query);

    if (response.isOkay) {
      final result = response.results.first;
      final location = result.geometry!.location;

      // 지도 이동 및 마커 추가
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(location.lat, location.lng),
      ));

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(result.placeId),
            position: LatLng(location.lat, location.lng),
            infoWindow: InfoWindow(title: result.name),
          ),
        );
        _autoCompleteResults.clear();
      });
    } else {
      print('검색 실패: ${response.errorMessage}');
    }
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
            myLocationEnabled: true, // 현재 위치 파란 점 표시
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers, // 마커 표시
          ),
          // Search bar
          Positioned(
            top: 30,
            left: 25,
            right: 25,
            child: MapSearchBar(
              onSearchSubmitted: _onSearchSubmitted,
              onVoiceSearch: _onVoiceSearch,
              onSearchChanged: _getAutoCompleteResults, // 검색 입력 시 자동완성 결과 요청
            ),
          ),
          // 자동완성 결과 표시
          if (_autoCompleteResults.isNotEmpty)
            AutoCompleteList(
              autoCompleteResults: _autoCompleteResults,
              onSearchSubmitted: _onSearchSubmitted,
            ), // 위치버튼
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
    );
  }
}
