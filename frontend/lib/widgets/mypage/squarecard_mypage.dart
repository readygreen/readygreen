import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class SquareCardMypage extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color textColor;
  final String? imageUrl;
  final String? subtitle;
  final Color subtitleColor;
  final Widget? child;

  const SquareCardMypage({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.backgroundGradient,
    this.textColor = Colors.black,
    this.imageUrl,
    this.subtitle,
    this.subtitleColor = AppColors.greytext,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth / 2.5,
      height: deviceWidth / 2.3,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: backgroundGradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 1.2),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    imageUrl!,
                    // width: deviceWidth / 4.6,
                    height: deviceWidth / 4.3,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 5),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Align(
                  alignment: Alignment.center, // 텍스트를 중앙에 정렬
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14, // 작은 텍스트 크기
                      color: subtitleColor, // 색상 설정 (필요에 따라 변경 가능)
                    ),
                  ),
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
