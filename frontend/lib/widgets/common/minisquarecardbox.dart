import 'package:flutter/material.dart';

class MiniSquareCardBox extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color textColor;
  final String? imageUrl;
  final String? subtitle; // 하단에 표시할 작은 텍스트 추가

  final Widget? child;

  const MiniSquareCardBox({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.backgroundGradient,
    this.textColor = Colors.black,
    this.imageUrl,
    this.subtitle, // subtitle 매개변수 추가

    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth / 3.5,
      height: deviceWidth / 3.5,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: backgroundGradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, // 아이템을 수평 중앙 정렬
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 7.0),
                child: Image.asset(
                  imageUrl!,
                  height: deviceWidth / 6,
                  fit: BoxFit.fitWidth,
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
