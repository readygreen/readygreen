import 'package:flutter/material.dart';

class MyBadgePage extends StatelessWidget {
  const MyBadgePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 배지'),
        backgroundColor: Colors.green, // AppBar 색상 설정
      ),
      body: const Center(
        child: Text('내 배지 페이지입니다.'),
      ),
    );
  }
}
