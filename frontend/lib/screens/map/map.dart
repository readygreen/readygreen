import 'package:flutter/material.dart';
import 'package:readygreen/bottom_navigation.dart';

class NaverMapApp extends StatelessWidget {
  const NaverMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '지도',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
