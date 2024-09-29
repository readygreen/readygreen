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
    _loadStoreFortune();
  }

// 로컬 스토리지에서 운세 데이터를 불러오는 함수
  Future<void> _loadStoreFortune() async {
    final storedFortune = await storage.read(key: 'fortune'); // 저장된 운세 불러오기
    setState(() {
      fortune = storedFortune ?? '운세 정보를 불러올 수 없습니다.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: deviceWidth,
        height: 500,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '오늘의 운세',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(fortune),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: const Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
