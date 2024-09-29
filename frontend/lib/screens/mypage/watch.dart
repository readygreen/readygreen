import 'package:flutter/material.dart';
import 'dart:math';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';
import 'package:readygreen/widgets/mypage/cardbox_notice.dart';
import 'package:readygreen/api/watch_api.dart';

class WatchPage extends StatefulWidget {
  @override
  _WatchPageState createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  List<int> randomNumbers = [];
  final WatchApi watchApi = WatchApi();

  @override
  void initState() {
    super.initState();
    _makeWatchNum();
  }

  void _makeWatchNum() {
    setState(() {
      // 1부터 9까지의 숫자 중에서 랜덤으로 6개의 숫자를 생성
      randomNumbers = List.generate(6, (index) => Random().nextInt(10));
    });
    _sendWatchCode();
  }

  void _sendWatchCode() async {
    String watchNumber = randomNumbers.join('');
    print('보낼 워치 코드: $watchNumber');

    // API 요청
    String response = await watchApi.watchNum(watchNumber: watchNumber);
    print('API 응답: $response');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BgcontainerMypage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        '워치 연결하기',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              CardboxNotice(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    Text(
                      '기기 연결을 위해',
                      style: TextStyle(fontSize: 17),
                    ),
                    Row(
                      children: [
                        Text(
                          '아래 ',
                          style: TextStyle(fontSize: 17),
                        ),
                        Text(
                          '인증코드',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '를',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '워치 화면',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '에 입력해주세요',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                    SizedBox(height: 80),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: randomNumbers.map((number) {
                        return Container(
                          margin: const EdgeInsets.all(1.0), // 박스 간격
                          padding: const EdgeInsets.all(15.0), // 내부 여백
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 207, 207, 207),
                                width: 1), // 테두리
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 120),
                    ElevatedButton(
                      onPressed: _makeWatchNum, // 버튼 클릭 시 랜덤 숫자 새로 생성
                      child: Text('인증코드 다시 받기',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        minimumSize: Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
