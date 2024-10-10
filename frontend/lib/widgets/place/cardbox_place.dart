import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/map/resultmap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // Random을 사용하기 위해 추가

class CardBoxPlace extends StatefulWidget {
  final List<Map<String, String>> places;
  final String selectedCategory;

  const CardBoxPlace({
    super.key,
    required this.places,
    required this.selectedCategory,
  });

  @override
  _CardBoxPlaceState createState() => _CardBoxPlaceState();
}

class _CardBoxPlaceState extends State<CardBoxPlace> {
  final Map<int, String> imageCache = {};

  // 한글 카테고리를 영어로 매핑하는 Map
  final Map<String, String> categoryMapping = {
    '전체': 'citu=]y',
    '맛집': 'restaurant',
    '카페': 'cafe',
    '편의점': 'supermarket',
    '은행': 'bank',
    '병원': 'hospital',
    '약국': 'pharmacy',
    '영화관': 'cinema',
    '놀거리': 'entertainment',
    '헬스장': 'gym',
    '공원': 'park',
  };

  Future<void> loadImages() async {
    String category =
        categoryMapping[widget.selectedCategory] ?? 'all'; // 한글 카테고리를 영어로 변환

    for (var i = 0; i < widget.places.length; i++) {
      String imageUrl = await fetchImageUrl(category, i); // 영어로 변환된 카테고리 사용

      // setState() 호출 전에 mounted 상태 확인
      if (mounted) {
        setState(() {
          imageCache[i] = imageUrl;
        });
      }
    }
  }

  Future<String> fetchImageUrl(String category, int index) async {
    // print('category $category');
    const String accessKey = 'Tb5m_5NwxbsmqkmYjx5_8sPmhHnXxMhfUTPN3JsH_gQ';
    final String url =
        'https://api.unsplash.com/search/photos?query=$category&client_id=$accessKey&page=${index + 1}';

    // print('url $url');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        // 랜덤 인덱스를 선택하기 위해 Random 클래스 사용
        final randomIndex = Random().nextInt(data['results'].length);
        return data['results'][randomIndex]['urls']['small'];
      }
    }
    return 'https://picsum.photos/150/150';
  }

  @override
  void initState() {
    super.initState();

    // print로 places 값을 출력
    print('Received places 받은거! : ${widget.places}');
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        width: deviceWidth,
        constraints: BoxConstraints(
          minHeight: deviceHeight * 0.2,
        ),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 18,
          ),
          child: Column(
            children: widget.places.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, String> place = entry.value;
              final String imageUrl =
                  imageCache[index] ?? 'https://picsum.photos/150/150';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place['name'] ?? '이름 없음',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                place['address'] ?? '주소 정보 없음',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () {
                                  // 위도와 경도를 double 타입으로 변환
                                  double latitude =
                                      double.parse(place['latitude']!);
                                  double longitude =
                                      double.parse(place['longitude']!);
                                  print('위더 경도 려깃지렁 $latitude, $longitude');
                                  print(place['name']);
                                  print(place['address']);
                                  print(place['id']);
                                  // ResultMapPage로 이동하며 데이터 전달
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultMapPage(
                                        lat: latitude, // 위도
                                        lng: longitude, // 경도
                                        placeName: place['name']!, // 장소 이름
                                        address: place['address'] ??
                                            '주소 정보 없음', // 주소
                                        searchQuery:
                                            place['name']!, // 검색 쿼리로 이름 사용
                                        placeId: place['id']!, // 장소 ID
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  foregroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(
                                      color: AppColors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  '지도보기',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != widget.places.length - 1)
                    const Divider(
                      color: AppColors.grey,
                      thickness: 1,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
