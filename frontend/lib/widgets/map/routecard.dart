import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class RouteCard extends StatefulWidget {
  final List<String> routeDescriptions; // 경로 설명 리스트

  final Function onClose; // 닫기 콜백

  const RouteCard(
      {super.key, required this.routeDescriptions, required this.onClose});

  @override
  _RouteCardState createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width; // 화면 너비 가져오기

    return SizedBox(
      height: 115,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.routeDescriptions.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: screenWidth, // 가로 너비를 화면 너비로 설정
            child: Card(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '경로 설명 ${index + 1}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            widget.onClose(); // 닫기 버튼 클릭 시 콜백 실행
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.routeDescriptions[index],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
