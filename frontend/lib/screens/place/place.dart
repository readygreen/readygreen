import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/widgets/place/cardbox_place.dart';

class PlacePage extends StatefulWidget {
  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  // 선택된 카테고리 상태를 관리할 변수
  String selectedCategory = '전체';

  // 한글 카테고리를 영어로 변환하는 매핑 테이블
  final Map<String, String> categoryMapping = {
    '전체': 'all',
    '맛집': 'restaurant',
    '편의점': 'convenience store',
    '은행': 'bank',
    '병원': 'hospital',
    '약국': 'pharmacy',
    '영화관': 'cinema',
    '미용실': 'hair salon',
    '놀거리': 'entertainment',
    '헬스장': 'gym',
    '공원': 'park',
  };

  // 카테고리 목록 (한글)
  final List<String> categories = [
    '전체',
    '맛집',
    '편의점',
    '은행',
    '병원',
    '약국',
    '영화관',
    '미용실',
    '놀거리',
    '헬스장',
    '공원',
  ];

  // 예시 데이터 (카테고리별 장소 정보)
  final List<Map<String, String>> places = [
    {
      'name': '삼성화재 유성연수원',
      'category': '맛집',
      'description': '대전 유성구 동서대로 98-39',
      'distance': '6.9km',
    },
    {
      'name': '스타벅스',
      'category': '맛집',
      'description': '대전 유성구 동서대로 98-39',
      'distance': '2.5km',
    },
    {
      'name': '편의점1',
      'category': '편의점',
      'description': '대전 유성구 동서대로 98-39',
      'distance': '2.5km',
    },
    {
      'name': '은행',
      'category': '은행',
      'description': '대전 유성구 동서대로 98-39',
      'distance': '2.5km',
    },
    // 추가 장소 데이터...
  ];

  // 선택한 카테고리에 맞는 장소 목록 필터링
  List<Map<String, String>> get filteredPlaces {
    if (selectedCategory == '전체') {
      return places;
    } else {
      return places
          .where((place) => place['category'] == selectedCategory)
          .toList();
    }
  }

  // 선택된 카테고리를 영어로 변환하는 함수
  String getEnglishCategory(String koreanCategory) {
    return categoryMapping[koreanCategory] ?? 'default';
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
                    Text(
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

              // CardBoxPlace 부분, 필터링된 장소 목록을 전달
              CardBoxPlace(
                places: filteredPlaces
                    .asMap()
                    .entries
                    .map((entry) => {
                          'name': entry.value['name']!,
                          'category': getEnglishCategory(
                              entry.value['category']!), // 영어 카테고리 변환
                          'description': entry.value['description']!,
                          'distance': entry.value['distance']!,
                          'imageIndex': entry.key.toString(), // 장소 인덱스 추가
                        })
                    .toList(), // 필터링된 장소 리스트 전달
              ),
            ],
          ),
        ),
      ),
    );
  }
}
