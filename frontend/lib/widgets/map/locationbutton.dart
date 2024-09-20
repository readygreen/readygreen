import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final Function onTap;
  final double screenWidth;

  const LocationButton(
      {required this.onTap, required this.screenWidth, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: screenWidth * (40 / 360),
        height: screenWidth * (40 / 360),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * (6 / 360)),
          child: const Icon(
            Icons.my_location_outlined,
            color: Color(0xFF85B6FF),
          ),
        ),
      ),
    );
  }
}
