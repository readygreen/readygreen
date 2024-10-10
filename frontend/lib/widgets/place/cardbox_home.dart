import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/place_api.dart'; // place_api import
import 'dart:math'; // Random을 사용하기 위해 추가

class CardBoxHome extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  const CardBoxHome({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  _CardBoxHomeState createState() => _CardBoxHomeState();
}

class _CardBoxHomeState extends State<CardBoxHome> {
  List<dynamic> places = [];
  final placeApi = PlaceApi();

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    try {
      final response = await placeApi.getAllNearbyPlaces(
        userLatitude: widget.userLatitude,
        userLongitude: widget.userLongitude,
      );

      setState(() {
        places = response;
      });
    } catch (e) {
      print('Failed to load places: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return places.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // 카드 박스 형태로 3개의 장소만 표시
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: places.length > 3 ? 3 : places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이미지 URL이 없을 경우 기본 이미지 사용
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.network(
                            place['imageUrl'] ?? 'https://picsum.photos/150/150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                '', // 기본 이미지 파일 경로
                                fit: BoxFit.cover,
                              );
                            },
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
                                  // 지도 보기 버튼 클릭 시 동작
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
                  );
                },
              ),
              const SizedBox(height: 10),
              // 더보기 버튼 추가
              ElevatedButton(
                onPressed: () {
                  // 더보기 페이지로 이동하는 코드
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MorePlacesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                  '더보기',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          );
  }
}

class MorePlacesScreen extends StatelessWidget {
  const MorePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("더 많은 장소 보기"),
      ),
      body: const Center(
        child: Text("여기에서 모든 장소를 볼 수 있습니다."),
      ),
    );
  }
}
