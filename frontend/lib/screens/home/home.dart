import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:readygreen/api/main_api.dart';
import 'package:readygreen/widgets/common/textbutton.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/modals/weather_modal.dart';
import 'package:readygreen/widgets/modals/luck_modal.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final NewMainApi api = NewMainApi();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final String apiKey =
      'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M'; // Google API Key 추가

  @override
  void initState() {
    super.initState();
    _storeLocation(); // 위치 정보 저장 함수 호출
    _storeFortune(); // 페이지가 로드될 때 운세 데이터 로드 및 저장
  }

  // 위치 권한 요청 및 저장
  Future<void> _storeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스 비활성화');
    }

    // 위치 권한 요청
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한 없음');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한 영구 거부');
    }

    // 현재 위치 가져오기
    Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 위치 정보를 스토리지에 저장
    await storage.write(key: 'latitude', value: location.latitude.toString());
    await storage.write(key: 'longitude', value: location.longitude.toString());
    print('위치 저장 완료: ${location.latitude}, ${location.longitude}');

    // // 위도 경도를 사용해 주소 찾기 (한국어로)
    // _getAddressFromLatLng(location.latitude, location.longitude);
  }

  // // Google Geocoding API를 사용하여 위도와 경도로 주소를 한국어로 찾는 함수
  // Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
  //   final url =
  //       'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&language=ko&key=$apiKey';

  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       print(data);

  //       if (data['results'].isNotEmpty) {
  //         String address = data['results'][0]['formatted_address'];

  //         // 주소를 스토리지에 저장
  //         await storage.write(key: 'address', value: address);
  //         print('주소 저장 완료: $address');
  //       } else {
  //         print("주소 데이터를 찾을 수 없습니다.");
  //       }
  //     } else {
  //       print("API 호출 실패: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("주소를 가져오는 중 오류 발생: $e");
  //   }
  // }

  // 현재 날짜 가져오기
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  // 운세 요청
  Future<void> _storeFortune() async {
    final String currentDate = _getCurrentDate();
    final String? storedDate = await storage.read(key: 'fortuneDate');

    if (storedDate != currentDate) {
      final fortune = await api.getFortune();
      if (fortune != null) {
        await storage.write(key: 'fortune', value: fortune);
        await storage.write(key: 'fortuneDate', value: currentDate); // 현재 날짜 저장
        print('운세 저장 완료: $fortune');
      }
    } else {
      print('오늘은 이미 운세를 받았습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '언제그린',
                      style: TextStyle(
                        fontFamily: 'LogoFont',
                        color: AppColors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const WeatherModal();
                        },
                      );
                    },
                    child: SquareCardBox(
                      title: '날씨',
                      textColor: Colors.black,
                      imageUrl: 'assets/images/w-sun.png',
                      backgroundGradient: LinearGradient(
                        colors: [AppColors.weaherblue, AppColors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      subtitle: '맑음',
                      subtitleColor: AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const FortuneModal();
                        },
                      );
                    },
                    child: SquareCardBox(
                      title: '오늘의운세',
                      backgroundColor: AppColors.darkblue,
                      textColor: AppColors.white,
                      imageUrl: 'assets/images/luck.png',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: const [
                CardBox(title: '자주가는목적지', height: 180),
              ],
            ),
            const SizedBox(height: 16),
            const CardBox(title: '최근 목적지'),
            const SizedBox(height: 16),
            const CardBox(title: '현재 위치 --동 장소 추천'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CustomButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
