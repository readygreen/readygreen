import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

class CurrentLocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String _currentAddress = '';
  String _currentPlaceName = '';

  final placesApi = GoogleMapsPlaces(
      apiKey:
          'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M'); // Google Places API 초기화

  // 현재 위치 정보에 접근하기 위한 getter
  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  String get currentPlaceName => _currentPlaceName;

  // 위치 업데이트 함수
  Future<void> updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();

      _currentPosition = position;
      notifyListeners(); // 위치 정보가 업데이트 되었음을 알림

      // Google Places API로 장소 검색
      final response = await placesApi.searchByText(
        '${position.latitude},${position.longitude}',
        language: 'ko',
      );

      if (response.isOkay && response.results.isNotEmpty) {
        final place = response.results.first;
        _currentPlaceName = place.name ?? '알 수 없음';
        _currentAddress = place.formattedAddress ?? '주소 정보 없음';

        if (RegExp(r'^[0-9\-]+$').hasMatch(_currentPlaceName)) {
          _currentPlaceName = _currentAddress; // 주소를 장소 이름 대신 사용
        }

        if (_currentPlaceName.startsWith('대한민국 대전광역시')) {
          _currentPlaceName =
              _currentAddress.replaceFirst('대한민국 대전광역시', '').trim();
        }

        print('현재 위치 $_currentPlaceName');
        print('현재 위치 $_currentAddress');
        notifyListeners(); // 주소 정보 업데이트
      } else {
        print('Google Places API로 주소 정보를 가져오지 못했습니다.');
      }
    } catch (e) {
      print('위치 정보를 가져오는 데 실패했습니다: $e');
    }
  }
}
