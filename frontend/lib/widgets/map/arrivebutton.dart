import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/map/mapdirection.dart';

class ArriveButton extends StatelessWidget {
  final String text;
  final Color borderColor; // 테두리 색상
  final Color textColor; // 텍스트 색상
  final IconData iconData; // 이모티콘 (아이콘)
  // final VoidCallback onPressed; // 버튼 클릭 이벤트 처리

  const ArriveButton({
    super.key,
    this.text = "도착지", // 텍스트 기본 값
    this.borderColor = AppColors.green, // 테두리 기본 색상 (초록색)
    this.textColor = AppColors.green, // 텍스트 기본 색상 (초록색)
    this.iconData = Icons.navigation, // 기본 이모티콘 (도착지 아이콘)
    // required this.onPressed, // 클릭 이벤트를 외부에서 전달받음
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('도착지 버튼이 눌렸습니다.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapDirectionPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 15,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조정
            children: [
              Icon(
                iconData, // 이모티콘 아이콘
                color: textColor, // 아이콘 색상
                size: 20, // 아이콘 크기
              ),
              const SizedBox(width: 5), // 아이콘과 텍스트 간격
              Text(
                text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
