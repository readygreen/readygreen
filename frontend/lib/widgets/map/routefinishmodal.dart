import 'package:flutter/material.dart';

class RouteFinishModal extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RouteFinishModal({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('길안내 종료'),
      content: const Text('도착지에 도착한 것 같네요. 길안내를 종료하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: onCancel,
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('종료'),
        ),
      ],
    );
  }
}
