import 'package:flutter/material.dart';

class DraggableRoute extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> routeDescriptions; // 경로 설명 리스트 추가

  const DraggableRoute({
    super.key,
    required this.scrollController,
    required this.routeDescriptions, // 경로 설명 리스트 받기
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.04,
      minChildSize: 0.04, // 최소 높이
      maxChildSize: 0.85, // 최대 높이
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 인디케이터
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              // 경로 설명 리스트
              Expanded(
                child: ListView.builder(
                  controller: scrollController, // 리스트가 스크롤 가능하도록 설정
                  itemCount: routeDescriptions.length, // 경로 설명 리스트 길이
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        routeDescriptions[index], // 경로 설명 출력
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
