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
      title: const Text('길안내 종료'),
      content: const Text('목적지에 도착하여 길안내를 종료합니다.'),
      actions: <Widget>[
        TextButton(
          onPressed: onConfirm,
          child: const Text('확인'),
        ),
      ],
    );
  }
}
