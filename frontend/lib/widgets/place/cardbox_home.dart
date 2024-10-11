import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:readygreen/screens/map/resultmap.dart';
import 'package:readygreen/screens/place/place.dart'; // Random을 사용하기 위해 추가

class CardBoxHome extends StatefulWidget {
  final List<Map<String, String>> places;

  const CardBoxHome({
    super.key,
    required this.places,
  });

  @override
  _CardBoxHomeState createState() => _CardBoxHomeState();
}

class _CardBoxHomeState extends State<CardBoxHome> {
  final Map<int, String> imageCache = {};

  Future<void> loadImages() async {
    String category = 'restaurant'; // 'restaurant' 카테고리로 고정

    for (var i = 0; i < widget.places.length; i++) {
      String imageUrl = await fetchImageUrl(category, i);

      if (mounted) {
        setState(() {
          imageCache[i] = imageUrl;
        });
      }
    }
  }

  Future<String> fetchImageUrl(String category, int index) async {
    const String accessKey = 'Tb5m_5NwxbsmqkmYjx5_8sPmhHnXxMhfUTPN3JsH_gQ';
    final String url =
        'https://api.unsplash.com/search/photos?query=$category&client_id=$accessKey&page=${index + 1}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final randomIndex = Random().nextInt(data['results'].length);
        return data['results'][randomIndex]['urls']['small'];
      }
    }
    return 'https://picsum.photos/150/150';
  }

  @override
  void initState() {
    super.initState();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 추가
              const Text(
                '가까운 장소 추천',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10), // 제목과 내용 사이 간격 추가

              // 기존 places 리스트 처리 부분
              Column(
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
                                      // 위도와 경도를 double 타입으로 변환 (null 체크 추가)
                                      double latitude =
                                          place['latitude'] != null
                                              ? double.parse(place['latitude']!)
                                              : 36.3551083; // 기본값 설정
                                      double longitude = place['longitude'] !=
                                              null
                                          ? double.parse(place['longitude']!)
                                          : 127.3379517; // 기본값 설정

                                      // null 체크 후 값 출력
                                      print('위도: $latitude, 경도: $longitude');
                                      print('장소 이름: ${place['name']}');
                                      print('주소: ${place['address']}');
                                      print('ID: ${place['id']}');

                                      // ResultMapPage로 이동하며 데이터 전달
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ResultMapPage(
                                            lat: latitude, // 위도
                                            lng: longitude, // 경도
                                            placeName: place['name'] ??
                                                '이름 없음', // null 체크
                                            address: place['address'] ??
                                                '주소 정보 없음', // null 체크
                                            searchQuery: place['name'] ??
                                                '검색어 없음', // null 체크
                                            placeId: place['id'] ??
                                                'ID 없음', // null 체크
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
                                  )
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

              // // 구분선과 '더보기' 텍스트 추가
              // const Divider(
              //   color: AppColors.grey, // 구분선 색상
              //   thickness: 1, // 구분선 두께
              // ),
              // const SizedBox(height: 5), // 구분선과 텍스트 사이 간격
              // Center(
              //   child: GestureDetector(
              //     onTap: () => {
              //       // 더보기 페이지로 이동하는 코드
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => PlacePage()),
              //       )
              //     },
              //     // onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage())),
              //     child: const Text(
              //       '더보기',
              //       style: TextStyle(
              //         fontSize: 14,
              //         color: AppColors.grey, // 텍스트 색상
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
