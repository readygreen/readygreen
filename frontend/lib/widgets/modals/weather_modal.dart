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
  List<Map<String, dynamic>> weatherData = []; // 날씨 정보를 저장하는 리스트
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
    String? lat = await storage.read(key: 'latitude');
    String? long = await storage.read(key: 'longitude');

    if (lat != null && long != null) {
      String latitude = lat.substring(0, 2);
      String longitude = long.substring(0, 3);

      var weatherResponse = await api.getWeather(latitude, longitude);

      if (weatherResponse != null) {
        setState(() {
          print(weatherResponse);
          weatherData = List<Map<String, dynamic>>.from(weatherResponse);
        });
      } else {
        setState(() {
          weatherData = [];
        });
      }
    } else {
      setState(() {
        weatherData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기기의 너비를 가져오기 위해 MediaQuery 사용
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: AppColors.white,
      child: Container(
        // 기기 너비의 90%를 사용하도록 설정 (조정 가능)
        width: deviceWidth * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '날씨 정보',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LogoFont',
                  color: AppColors.blue),
            ),
            const SizedBox(height: 16),
            weatherData.isEmpty
                ? const Text('날씨 정보를 불러오는 중...')
                : _buildWeatherInfo(), // 날씨 정보를 출력하는 위젯
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: const Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop(); // 모달 닫기
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 시간별 날씨 정보를 출력하는 위젯
  Widget _buildWeatherInfo() {
    return Column(
      children: weatherData.map((data) => _buildHourlyWeather(data)).toList(),
    );
  }

  // 시간별 날씨 정보를 표시하는 위젯
  Widget _buildHourlyWeather(Map<String, dynamic> data) {
    String time = '${data['time']}시';
    String temperature = '${data['temperature']}°C';
    String weatherImage = _getWeatherImage(data['sky'], data['rainy']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time), // 시간 출력
        Image.asset(weatherImage, width: 50, height: 50), // 날씨 이미지 출력
        Text(temperature), // 온도 출력
      ],
    );
  }

  // sky와 rainy 값을 기반으로 날씨 이미지를 반환하는 함수
  String _getWeatherImage(int sky, int rainy) {
    if (rainy > 50) {
      return 'assets/images/w-rain.png';
    } else if (sky == 1) {
      return 'assets/images/w-sun.png';
    } else if (sky == 3 | 4) {
      return 'assets/images/w-cloudy.png';
    }
    return 'assets/images/w-default.png'; // 기본 이미지
  }
}
