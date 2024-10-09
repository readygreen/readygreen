import 'package:flutter/material.dart';

class CardboxMypage extends StatelessWidget {
  final Widget title; // title을 Widget으로 받음
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget? child;
  final Widget? children;

  const CardboxMypage({
    super.key,
    required this.title, // title은 Widget이므로 required로 설정
    this.height = 150,
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
          horizontal: 25,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(
                  height: 10,
                ),
                if (child != null) child!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
