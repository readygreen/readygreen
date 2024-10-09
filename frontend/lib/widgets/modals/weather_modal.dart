import 'dart:convert'; // JSON 변환을 위해 필요
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/appcolors.dart';

class WeatherModal extends StatefulWidget {
  const WeatherModal({super.key});

  @override
  _WeatherModalState createState() => _WeatherModalState();
}

class _WeatherModalState extends State<WeatherModal> {
  List<Map<String, dynamic>> weatherData = []; // 날씨 정보를 저장하는 리스트
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadWeatherInfo(); // 모달이 열릴 때 날씨 정보를 불러옴
  }

  // 날씨 정보를 스토리지에서 불러오는 함수
  Future<void> _loadWeatherInfo() async {
    // 스토리지에서 저장된 날씨 데이터 불러오기
    final String? storedWeatherData = await storage.read(key: 'weather');

    if (storedWeatherData != null) {
      // JSON 문자열을 리스트로 변환
      List<dynamic> decodedWeatherData = jsonDecode(storedWeatherData);

      setState(() {
        weatherData = List<Map<String, dynamic>>.from(decodedWeatherData);
      });
    } else {
      setState(() {
        weatherData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: AppColors.white,
      child: Stack(
        children: [
          Container(
            width: deviceWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '날씨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LogoFont',
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                weatherData.isEmpty
                    ? const Text('날씨 정보를 불러오는 중...')
                    : _buildWeatherInfo(), // 날씨 정보를 출력하는 위젯
                const SizedBox(height: 16),
              ],
            ),
          ),
          // 닫기 버튼
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 30,
                color: AppColors.greytext,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
            ),
          ),
        ],
      ),
    );
  }

  // 시간별 날씨 정보를 출력하는 위젯
  Widget _buildWeatherInfo() {
    return Column(
      children: weatherData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = entry.value;

        // 첫 번째 데이터(현재 시간)와 나머지 데이터를 구분하여 스타일 적용
        if (index == 0) {
          return _buildCurrentWeather(data); // 첫 번째 데이터는 크게 표시
        } else {
          return _buildHourlyWeather(data); // 나머지 데이터는 기본 크기로 표시
        }
      }).toList(),
    );
  }

  // 현재 시간의 날씨 정보를 더 크게 표시하는 위젯
  Widget _buildCurrentWeather(Map<String, dynamic> data) {
    String temperature = '${data['temperature']}°C';
    String weatherImage = _getWeatherImage(data['sky'], data['rainy']);
    String weatherStatus = _getWeatherStatus(data['sky'], data['rainy']);

    return Column(
      children: [
        Image.asset(weatherImage, width: 120, height: 120),
        Text(
          temperature,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          weatherStatus,
          style: const TextStyle(fontSize: 15, color: AppColors.blue),
        ), // 날씨 상태
        const SizedBox(height: 16),
      ],
    );
  }

  // 시간별 날씨 정보를 표시하는 기본 크기의 위젯
  Widget _buildHourlyWeather(Map<String, dynamic> data) {
    String time = '${data['time']}시';
    String temperature = '${data['temperature']}°C';
    String weatherImage = _getWeatherImage(data['sky'], data['rainy']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(time), // 시간 출력
        Image.asset(weatherImage, width: 45, height: 45), // 작은 이미지
        Text(temperature), // 온도 출력
      ],
    );
  }

  // sky와 rainy 값을 기반으로 날씨 이미지를 반환하는 함수
  String _getWeatherImage(int sky, int rainy) {
    if (sky == 1) {
      return 'assets/images/w-sun.png'; // 맑음
    } else if (sky == 3) {
      return 'assets/images/w-suncloud.png'; // 구름 많음
    } else if (sky == 4) {
      return 'assets/images/w-cloudy.png'; // 흐림
    } else if (rainy == 1) {
      return 'assets/images/w-rain.png'; // 비
    } else if (rainy == 2) {
      return 'assets/images/w-rainsnow.png'; // 비눈
    } else if (rainy == 3) {
      return 'assets/images/w-snow.png'; // 눈
    } else if (rainy == 4) {
      return 'assets/images/w-rain.png'; // 소나기
    }

    return 'assets/images/w-default.png'; // 기본 이미지
  }

  // sky와 rainy 값을 기반으로 날씨 상태 텍스트 반환하는 함수
  String _getWeatherStatus(int sky, int rainy) {
    if (sky == 1) {
      return '맑음';
    } else if (sky == 3) {
      return '구름 많음';
    } else if (sky == 4) {
      return '흐림';
    } else if (rainy == 1) {
      return '비';
    } else if (rainy == 2) {
      return '비와 눈';
    } else if (rainy == 3) {
      return '눈';
    } else if (rainy == 4) {
      return '소나기';
    }

    return '알 수 없음';
  }
}
