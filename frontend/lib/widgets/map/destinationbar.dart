import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/screens/home/home.dart';

class DestinationBar extends StatelessWidget {
  final String currentLocation;
  final String destination;

  const DestinationBar({
    super.key,
    required this.currentLocation,
    required this.destination,
  });

  void handleBackNavigation(BuildContext context) {
    if (Navigator.canPop(context)) {
      // 스택에 화면이 남아있으면 pop
      Navigator.pop(context);
    } else {
      // 스택이 비어 있으면 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }
  String formatDestinationName(String destinationName) {
    // Check if "대전광역시" is present in the string
    if (destinationName.contains('대전광역시')) {
      // Find the position of "대전광역시" and return the substring starting after it
      int index = destinationName.indexOf('대한민국 대전광역시');
      destinationName =
          destinationName.substring(index + '대한민국 대전광역시'.length).trim();
      destinationName.substring(index + '대한민국 대전광역시'.length).trim();
    }

    // Trim long text to a maximum of 20 characters (example) and add "..." at the end

    return destinationName;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.black),
                onPressed: () {
                  handleBackNavigation(context);
                },
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.grey,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.share_location_rounded,
                              color: AppColors.blue),
                          const SizedBox(width: 5),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.65, // 화면 너비의 70%로 제한
                            child: Text(
                              formatDestinationName(currentLocation),
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                              maxLines: 1, // 최대 1줄로 설정
                              overflow: TextOverflow.ellipsis, // 넘치는 텍스트는 '...'로 표시
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.grey,
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.red),
                          const SizedBox(width: 5),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.65, // 화면 너비의 70%로 제한
                            child: Text(
                              formatDestinationName(destination),
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                              maxLines: 1, // 최대 1줄로 설정
                              overflow: TextOverflow.ellipsis, // 넘치는 텍스트는 '...'로 표시
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
