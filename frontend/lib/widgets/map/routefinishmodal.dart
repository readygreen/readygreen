import 'package:flutter/material.dart';

class RouteFinishModal extends StatelessWidget {
  final VoidCallback onConfirm;

  const RouteFinishModal({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        '길안내 종료',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        '목적지에 도착하여 길안내를 종료합니다.',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontSize: 16, // 버튼 글씨 크기
              // fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
