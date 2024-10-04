import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class DraggableRoute extends StatelessWidget {
  final Function onClose; // 닫기 콜백
  final List<String> routeDescriptions; // 경로 설명 리스트

  const DraggableRoute({
    super.key,
    required this.onClose, // 콜백 받기
    required this.routeDescriptions, // 경로 설명 리스트 받기
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15, // 최소 높이
      maxChildSize: 0.15, // 최대 높이
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // '경로 상세' 텍스트와 닫기 버튼을 한 줄에 배치
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "경로 상세", // 경로 상세 텍스트
                      style: TextStyle(
                        fontSize: 18, // 글씨 크기 설정
                        fontWeight: FontWeight.bold, // 텍스트 굵게 표시
                        color: AppColors.black, // 텍스트 색상 설정
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        onClose(); // 닫기 버튼 클릭 시 콜백 실행
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: routeDescriptions.length, // 경로 설명 리스트 개수
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          routeDescriptions[index], // 경로 설명 출력
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
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
