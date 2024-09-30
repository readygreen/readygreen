import 'package:flutter/material.dart';

class CardboxFeedback extends StatelessWidget {
  final String? title; // String?로 nullable 설정
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget? child;
  final Widget? children;

  const CardboxFeedback({
    super.key,
    this.title,
    this.height = 520,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.child,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
          children: [
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            SizedBox(width: 10),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
