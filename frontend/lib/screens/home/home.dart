import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
import 'package:readygreen/api/main_api.dart';
import 'package:readygreen/screens/map/mapdirection.dart';
import 'package:readygreen/widgets/common/textbutton.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/modals/weather_modal.dart';
import 'package:readygreen/widgets/modals/fortune_modal.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final NewMainApi api = NewMainApi();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String apiKey =
      'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M'; // Google API Key 추가
  bool isLoadingFortune = false; // 운세 로딩중
  Map<String, dynamic>? routeRecords = null;
  List<Map<String, dynamic>> _bookmarks = [];
  bool _showAllBookmarks = false;
  @override
  void initState() {
    super.initState();
    _fetchMainDate();
    _storeLocation(); // 위치 정보 저장 함수 호출
    _storeFortune(); //  운세 데이터 로드 및 저장
    _storeWeather();
    _loadWeatherInfo();
    
  }
  Future<void> _fetchMainDate()async {
      final data = await api.getMainData();
      print("data");
      setState(() {
        _bookmarks = data?['bookmarkDTOs'];
        routeRecords = data?['routeRecordDTO'];
      });
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
  }

  // 현재 날짜 가져오기
  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

// 운세 요청 및 저장
  Future<void> _storeFortune() async {
    setState(() {
      isLoadingFortune = true; // 운세 로딩 시작
    });

    final String currentDate = _getCurrentDate();
    final String? storedDate = await storage.read(key: 'fortuneDate');
    final String? storedFortune = await storage.read(key: 'fortune');

    if (currentDate != storedDate) {
      print('현재날짜 $currentDate // 저장날짜 $storedDate');
      final fortune = await api.getFortune();
      if (fortune != null) {
        if (fortune.contains('생일 정보가 없습니다')) {
          await storage.write(key: 'fortune', value: '111');
          print('운세1 $fortune');
          setState(() {
            isLoadingFortune = false; // 로딩 종료
          });
        } else {
          // 운세가 정상적으로 반환되면 스토리지에 저장
          await storage.write(key: 'fortune', value: fortune);
          print('운세2 $fortune');
          await storage.write(
              key: 'fortuneDate', value: currentDate); // 현재 날짜 저장
          setState(() {
            isLoadingFortune = false; // 로딩 종료
          });
        }
      }
    } else {
      if (storedFortune == '111') {
        final fortune = await api.getFortune();
        if (fortune != null) {
          if (fortune.contains('생일 정보가 없습니다')) {
            await storage.write(key: 'fortune', value: '111');
            print('운세3 $fortune');
            setState(() {
              isLoadingFortune = false; // 로딩 종료
            });
          } else {
            // 운세가 정상적으로 반환되면 스토리지에 저장
            await storage.write(key: 'fortune', value: fortune);
            print('운세4 $fortune');
            await storage.write(
                key: 'fortuneDate', value: currentDate); // 현재 날짜 저장
            setState(() {
              isLoadingFortune = false; // 로딩 종료
            });
          }
        }
      } else {
        print('이미 운세를 받았습니다');
        setState(() {
          isLoadingFortune = false; // 로딩 종료
        });
      }
    }
  }

  // 현재 시간 가져오기
  String _getCurrentHour() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH');
    return formatter.format(now);
  }

  // 날씨 요청
  List<Map<String, dynamic>> weatherData = []; // 날씨 정보를 저장하는 리스트
  String currentWeatherStatus = '맑음'; // 기본 날씨 상태
  String currentWeatherImage = 'assets/images/w-sun.png'; // 기본 날씨 아이콘

  Future<void> _storeWeather() async {
    // 현재 시간 비교
    final String currentHour = _getCurrentHour();
    final String? storedHour = await storage.read(key: 'weatherHour');

    // 스토리지에서 저장된 위도와 경도 읽기
    String? lat = await storage.read(key: 'latitude');
    String? long = await storage.read(key: 'longitude');

    if (lat != null && long != null) {
      String latitude = lat.substring(0, 2);
      String longitude = long.substring(0, 3);

      if (storedHour != currentHour) {
        var weatherResponse = await api.getWeather(latitude, longitude);

        if (weatherResponse != null) {
          if (mounted) {
            setState(() {
              print(weatherResponse);
              weatherData = List<Map<String, dynamic>>.from(weatherResponse);
            });
          }
          String weatherJson = jsonEncode(weatherData);
          await storage.write(key: 'weather', value: weatherJson);
          await storage.write(key: 'weatherHour', value: currentHour);
        }
      }
    }
  }
  String formatDestinationName(String destinationName) {
  // Check if "대전광역시" is present in the string
  if (destinationName.contains('대전광역시')) {
    // Find the position of "대전광역시" and return the substring starting after it
    int index = destinationName.indexOf('대전광역시');
    destinationName = destinationName.substring(index + '대전광역시'.length).trim();
  }

  // Trim long text to a maximum of 20 characters (example) and add "..." at the end
  if (destinationName.length > 16) {
    destinationName = destinationName.substring(0, 16) + '...';
  }

  return destinationName;
}
  // 저장된 날씨 정보를 스토리지에서 불러와 첫 번째 데이터 설정
  Future<void> _loadWeatherInfo() async {
    final String? storedWeatherData = await storage.read(key: 'weather');

    if (storedWeatherData != null) {
      List<dynamic> decodedWeatherData = jsonDecode(storedWeatherData);
      setState(() {
        weatherData = List<Map<String, dynamic>>.from(decodedWeatherData);
        if (weatherData.isNotEmpty) {
          // 첫 번째 데이터에서 현재 날씨를 가져옴
          currentWeatherImage =
              _getWeatherImage(weatherData[0]['sky'], weatherData[0]['rainy']);
          currentWeatherStatus =
              _getWeatherStatus(weatherData[0]['sky'], weatherData[0]['rainy']);
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                      title: '현재 날씨',
                      textColor: Colors.black,
                      imageUrl: currentWeatherImage, // 날씨 아이콘 변경
                      backgroundGradient: const LinearGradient(
                        colors: [AppColors.weaherblue, AppColors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      subtitle: currentWeatherStatus, // 날씨 상태 변경
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
                          return FortuneModal();
                        },
                      );
                    },
                    child: const SquareCardBox(
                      title: '오늘의 운세',
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '자주 가는 목적지',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _bookmarks.isNotEmpty
                            ? List.generate(
                                _showAllBookmarks
                                    ? _bookmarks.length
                                    : (_bookmarks.length > 0 ? 1 : 0), // Show only the first item initially
                                (index) {
                                  final bookmark = _bookmarks[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatDestinationName(bookmark['destinationName']),
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Text(
                                            //   bookmark['endLatitued'],
                                            //   style: const TextStyle(
                                            //     fontSize: 14,
                                            //     color: Colors.grey,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MapDirectionPage(
                                                  endLat: bookmark['latitude'],
                                                  endLng: bookmark['longitude'],
                                                  endPlaceName: bookmark['destinationName'],
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Colors.blue,
                                              width: 2.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            '길찾기',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : [const Text('자주 가는 목적지가 없습니다.')],
                      ),
                      const Divider( // Add this Divider to create the horizontal line
                        color: AppColors.greytext, // You can adjust the color
                        thickness: 1, // Adjust thickness for a more prominent line
                      ),
                      if (_bookmarks.length > 1)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAllBookmarks = !_showAllBookmarks;
                              });
                            },
                            child: Text(
                              _showAllBookmarks ? '접기' : '더보기',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15), // Add border radius
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최근 목적지', // Add the title here
                    style: TextStyle(
                      fontSize: 14,
                          color: Colors.grey,
                    ),
                  ), 
                  routeRecords != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${formatDestinationName(routeRecords?['endName']) ?? '알 수 없음'}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  print(routeRecords?['endName']);
                                  print(routeRecords?['endLatitude']);
                                  print(routeRecords?['endLongitude']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapDirectionPage(
                                        endLat: routeRecords?['endLatitude'],
                                        endLng: routeRecords?['endLongitude'],
                                        endPlaceName: routeRecords?['endName'],
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.green,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: AppColors.green,
                                    width: 2.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  '길찾기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Text('최근 목적지가 없습니다.'),
                ],
              ),
            ),


            const SizedBox(height: 16),
            const CardBox(title: '주변 장소'),
            const SizedBox(height: 16),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     CustomButton(),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
