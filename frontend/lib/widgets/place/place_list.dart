import 'package:flutter/material.dart';

class PlaceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> places = [
      {
        'title': '삼성화재 유성연수원',
        'address': '대전 유성구 동서대로 98-39',
        'distance': '6.9km',
        'imageUrl': 'https://via.placeholder.com/150'
      },
      {
        'title': '멋진 맛집',
        'address': '서울 강남구 맛집로 123',
        'distance': '3.2km',
        'imageUrl': 'https://via.placeholder.com/150'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 전체 Column 왼쪽 정렬
      children: places.map((place) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Row 내부 요소 왼쪽 정렬
            children: [
              Container(
                width: 100,
                height: 100,
                child: Image.network(
                  place['imageUrl']!,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                  children: [
                    Text(
                      place['title']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      place['address']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      place['distance']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft, // 버튼 왼쪽 정렬
                      child: ElevatedButton(
                        onPressed: () {
                          // 지도보기 버튼 동작 설정
                        },
                        child: Text('지도보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
