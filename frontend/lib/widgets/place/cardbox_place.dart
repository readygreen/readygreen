import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위한 패키지

class CardBoxPlace extends StatefulWidget {
  final List<Map<String, String>> places; // 장소 리스트

  const CardBoxPlace({
    super.key,
    required this.places, // 필수 입력값으로 변경
  });

  @override
  _CardBoxPlaceState createState() => _CardBoxPlaceState();
}

class _CardBoxPlaceState extends State<CardBoxPlace> {
  // Unsplash API로 카테고리별 랜덤 이미지 URL 생성 함수
  Future<String> fetchImageUrl(String category, int index) async {
    final String accessKey =
        'Tb5m_5NwxbsmqkmYjx5_8sPmhHnXxMhfUTPN3JsH_gQ'; // Unsplash API access key
    // 요청에 index를 추가하여 각 장소마다 고유한 이미지 요청
    final String url =
        'https://api.unsplash.com/search/photos?query=$category&client_id=$accessKey&page=${index + 1}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['urls']['small']; // 첫 번째 이미지의 URL 반환
      }
    }
    return 'https://via.placeholder.com/150'; // 기본 이미지 URL 반환
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
            children: widget.places.map((place) {
              final index = widget.places.indexOf(place);
              final String category = place['category']!;

              return FutureBuilder<String>(
                future: fetchImageUrl(category, index), // 이미지 URL 비동기 호출
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // 로딩 상태
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final String imageUrl = snapshot.data ??
                        'https://via.placeholder.com/150'; // 이미지 URL

                    return Column(
                      children: [
                        // 카드 내용
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 왼쪽 이미지 부분
                              Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  imageUrl, // Unsplash 이미지 URL 적용
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 오른쪽 텍스트 설명 부분
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      place['description']!,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 5),
                                    // 지도보기 버튼을 아래에 배치
                                    ElevatedButton(
                                      onPressed: () {
                                        // 지도 보기 버튼 클릭 동작
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.white, // 버튼 배경색
                                        foregroundColor:
                                            Colors.grey, // 버튼 텍스트 색상
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5), // 패딩
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          // 모서리 둥글게
                                          borderRadius: BorderRadius.circular(
                                              30), // 모서리 둥근 정도
                                          side: BorderSide(
                                            color: AppColors.grey, // 테두리 색상
                                            width: 1.0, // 테두리 두께
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '지도보기',
                                        style: TextStyle(
                                          fontSize: 13, // 텍스트 크기
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 구분선: 마지막 아이템이 아니면 구분선 추가
                        if (index != widget.places.length - 1)
                          const Divider(
                            color: AppColors.grey, // 구분 선 색상
                            thickness: 1, // 구분 선 두께
                            indent: 0, // 왼쪽 여백
                            endIndent: 0, // 오른쪽 여백
                          ),
                      ],
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
