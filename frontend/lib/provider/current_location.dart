import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String _currentAddress = '';
  String _currentPlaceName = '';

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

      // 위도와 경도로 주소 가져오기
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.country}";
        _currentPlaceName = place.name ?? "알 수 없음";
        notifyListeners(); // 주소 정보 업데이트
      }
      print('여기지롱~!!!!!!!!!!!!!!!!!!!');
      print(_currentAddress);
      print(_currentPlaceName);
      print(currentAddress);
      print(currentPlaceName);
    } catch (e) {
      print('위치 정보를 가져오는 데 실패했습니다: $e');
    }
  }
}
