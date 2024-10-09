import 'package:flutter/material.dart';

class CardBox extends StatelessWidget {
  final String title;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Widget? child;
  final Widget? children;

  const CardBox({
    super.key,
    required this.title,
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
          vertical: 15,
          horizontal: 18,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
