import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/widgets/place/cardbox_place.dart';
import 'package:readygreen/api/place_api.dart'; // API 파일 가져오기
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  final PlaceApi placeApi = PlaceApi();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String selectedCategory = '전체';
  List<Map<String, String>> places = [];
  bool isLoading = false; // 로딩 상태 관리

  final Map<String, String> categoryMapping = {
    '전체': 'all',
    '맛집': 'food',
    '카페': 'cafe',
    '편의점': 'conv',
    '은행': 'bank',
    '병원': 'hospital',
    '약국': 'med',
    '영화관': 'movie',
    '놀거리': 'play',
    '헬스장': 'gym',
    '공원': 'park',
  };

  final List<String> categories = [
    '전체',
    '맛집',
    '카페',
    '편의점',
    '은행',
    '병원',
    '약국',
    '영화관',
    '놀거리',
    '헬스장',
    '공원',
  ];
// 장소 데이터 API로부터 받아오는 함수
  Future<void> _getPlace() async {
    setState(() {
      isLoading = true; // 로딩 시작
    });

    // 저장된 위도와 경도를 가져오기
    String? latitudeStr = await storage.read(key: 'latitude');
    String? longitudeStr = await storage.read(key: 'longitude');

    // String? 타입을 double로 변환
    double userLatitude =
        latitudeStr != null ? double.parse(latitudeStr) : 36.3551083;
    double userLongitude =
        longitudeStr != null ? double.parse(longitudeStr) : 127.3379517;

    try {
      List<dynamic> placeData;

      // '전체' 카테고리 선택 시 전체 장소 추천 API 호출
      if (selectedCategory == '전체') {
        placeData = await placeApi.getAllNearbyPlaces(
          userLatitude: userLatitude,
          userLongitude: userLongitude,
        );
      } else {
        // 선택된 카테고리에 맞는 type 설정
        String type = categoryMapping[selectedCategory] ?? 'all';

        // 로그로 카테고리 및 타입 확인
        print('Selected Category: $selectedCategory, Type: $type');

        // API 호출
        placeData = await placeApi.getPlaces(
          type: type,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
        );
      }
      setState(() {
        print('placeData $placeData');
        places = placeData.map<Map<String, String>>((place) {
          return {
            'id': place['id'].toString(), // ID 추가
            'name': place['name'].toString(), // 이름
            'address': place['address'].toString(), // 주소
            'latitude': place['latitude'].toString(), // 위도
            'longitude': place['longitude'].toString(), // 경도
          };
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Failed to load places: $error');
      if (mounted) {
        setState(() {
          places = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPlace(); // 화면이 처음 로드될 때 API 호출
  }

  List<Map<String, String>> get filteredPlaces {
    if (selectedCategory == '전체') {
      return places; // 전체를 선택한 경우 모든 장소 반환
    } else {
      // '병원'은 type이 'hospital'인 데이터 필터링
      final filtered = places.where((place) {
        return place['type'] == categoryMapping[selectedCategory];
      }).toList();
      print('Filtered Places ($selectedCategory): $filtered');
      return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BackgroundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/placepage.png',
                      height: 200,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '지금 내 주변 핫플은?',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 카테고리 선택 부분
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                          _getPlace(); // 카테고리 변경 시 API 다시 호출
                        },
                        child: Chip(
                          label: Text(
                            categories[index],
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: selectedCategory == categories[index]
                              ? AppColors.green
                              : AppColors.grey,
                          labelStyle: TextStyle(
                            color: selectedCategory == categories[index]
                                ? Colors.white
                                : Colors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selectedCategory == categories[index]
                                  ? AppColors.green
                                  : AppColors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // 로딩 상태일 때는 로딩 인디케이터 표시
              if (isLoading)
                // Center(child: CircularProgressIndicator())
                const Center(child: Text('로딩중..'))
              else if (places.isEmpty)
                const Center(child: Text('해당 카테고리의 장소를 찾을 수 없습니다.'))
              else
                CardBoxPlace(
                  places: places
                      .asMap()
                      .entries
                      .map((entry) => {
                            'id': entry.value['id'] ?? '0', // ID 전달
                            'name': entry.value['name']!, // 이름
                            'address':
                                entry.value['address'] ?? '주소 정보 없음', // 주소
                            'latitude': entry.value['latitude']!, // 위도
                            'longitude': entry.value['longitude']!, // 경도
                            'imageIndex': entry.key.toString(),
                          })
                      .toList(),
                  selectedCategory: selectedCategory, // 페이지에서 선택한 카테고리 전달
                )
            ],
          ),
        ),
      ),
    );
  }
}
