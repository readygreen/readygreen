import 'package:flutter/material.dart';

class SquareCardBox extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final String? imageUrl;
  final Widget? child;

  const SquareCardBox({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.imageUrl,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      height: deviceWidth / 2.5,
      width: deviceWidth / 2.5,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor, // 명시적으로 색상 설정
              ),
            ),
            if (imageUrl != null)
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  imageUrl!,
                  width: deviceWidth / 4,
                  height: deviceWidth / 4,
                  fit: BoxFit.cover,
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
