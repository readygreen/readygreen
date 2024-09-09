import 'package:flutter/material.dart';

class SquareCardBox extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final String? imageUrl;

  const SquareCardBox({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.imageUrl,
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
          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트는 왼쪽 정렬
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (imageUrl != null)
              Align(
                // 이미지만 가운데 정렬
                alignment: Alignment.center,
                child: Image.asset(
                  imageUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
