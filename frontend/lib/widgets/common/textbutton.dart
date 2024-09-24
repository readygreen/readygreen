import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color borderColor; // 테두리 색상
  final Color textColor; // 텍스트 색상

  // 기본 값으로 초록색과 "길찾기" 텍스트 설정
  const CustomButton({
    super.key,
    this.text = "길찾기", // 텍스트 기본 값
    this.borderColor = AppColors.green, // 테두리 기본 색상 (초록색)
    this.textColor = AppColors.green, // 텍스트 기본 색상 (초록색)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }
}
