import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FortuneModal extends StatefulWidget {
  const FortuneModal({Key? key}) : super(key: key);

  @override
  _FortuneModalState createState() => _FortuneModalState();
}

class _FortuneModalState extends State<FortuneModal> {
  String fortune = 'Loading...';
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadStoredFortune();
  }

// 로컬 스토리지에서 운세 데이터를 불러오는 함수
  Future<void> _loadStoredFortune() async {
    final storedFortune = await storage.read(key: 'fortune'); // 저장된 운세 불러오기
    setState(() {
      fortune = storedFortune ?? '운세 정보를 불러올 수 없습니다.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('오늘의 운세'),
      content: Text(fortune),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
