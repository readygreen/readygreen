import 'package:flutter/material.dart';
import 'dart:async';
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
  Timer? _timer;
  Duration _remainingTime = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _makeWatchNum();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // 기존 타이머가 있으면 취소
    _remainingTime = Duration(minutes: 5); // 시간을 5분으로 초기화
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _makeWatchNum() {
    setState(() {
      // 1부터 9까지의 숫자 중에서 랜덤으로 6개의 숫자를 생성
      randomNumbers = List.generate(6, (index) => Random().nextInt(10));
    });
    _sendWatchCode();
    _startTimer();
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
                    SizedBox(height: 70),
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
                    SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: randomNumbers.map((number) {
                        return Container(
                          width: 47.0,
                          margin: const EdgeInsets.all(1.0), // 박스 간격
                          padding: const EdgeInsets.all(15.0), // 내부 여백
                          alignment: Alignment.center,
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
                    SizedBox(height: 70),
                    Text(
                      '인증코드 유효 시간',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatDuration(_remainingTime),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                    SizedBox(height: 70),
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
