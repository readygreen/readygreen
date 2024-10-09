import 'package:flutter/material.dart';

class FeedbackContent extends StatelessWidget {
  final String? title; // String?로 nullable 설정
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget? child;
  final Widget? children;

  const FeedbackContent({
    super.key,
    this.title, // required 제거
    this.height = 450,
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
          vertical: 20,
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) // title이 있을 경우에만 렌더링
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                const SizedBox(height: 10),
                if (child != null) child!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
