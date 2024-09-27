import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class WeatherModal extends StatelessWidget {
  const WeatherModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: const Text('날씨 정보'),
      content: const Text('현재 날씨는 맑음입니다.'),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop(); // 모달 닫기
          },
        ),
      ],
    );
  }
}
