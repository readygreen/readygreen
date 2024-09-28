import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/api/main_api.dart';
import 'package:readygreen/constants/appcolors.dart';

class WeatherModal extends StatefulWidget {
  const WeatherModal({super.key});

  @override
  _WeatherModalState createState() => _WeatherModalState();
}

class _WeatherModalState extends State<WeatherModal> {
  String weatherInfo = '날씨 정보를 불러오는 중...'; // 기본 상태
  final NewMainApi api = NewMainApi();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadWeatherInfo(); // 모달이 열릴 때 날씨 정보를 불러옴
  }

  // 날씨 정보를 스토리지에서 불러오거나 API를 통해 가져오는 함수
  Future<void> _loadWeatherInfo() async {
    // 스토리지에서 저장된 위도와 경도 읽기
    String? latitude = await storage.read(key: 'latitude');
    String? longitude = await storage.read(key: 'longitude');

    if (latitude != null && longitude != null) {
      // 위도와 경도가 있으면 날씨 API 호출
      var weatherData = await api.getWeather(latitude, longitude);

      if (weatherData != null) {
        setState(() {
          weatherInfo =
              "현재 날씨: ${weatherData['description']}, 온도: ${weatherData['temperature']}°C";
        });
      } else {
        setState(() {
          weatherInfo = '날씨 정보를 가져오는 데 실패했습니다.';
        });
      }
    } else {
      setState(() {
        weatherInfo = '위치 정보를 불러올 수 없습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: const Text('날씨 정보'),
      content: const Text('현재 날씨는 맑음입니다.'),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop(); // 모달 닫기
          },
        ),
      ],
    );
  }
}
