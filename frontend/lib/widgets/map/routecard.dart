import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class RouteCard extends StatefulWidget {
  final List<String> routeDescriptions;
  final Function onClose;
  // final PageController pageController; // 추가: PageController를 외부에서 받음

  const RouteCard({
    super.key,
    required this.routeDescriptions,
    required this.onClose,
    // required this.pageController, // PageController 생성자에 추가
  });

  @override
  _RouteCardState createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 115,
      child: PageView.builder(
        // controller: widget.pageController, // PageController 설정
        itemCount: widget.routeDescriptions.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: screenWidth,
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
                            widget.onClose();
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
