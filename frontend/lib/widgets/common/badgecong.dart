import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:readygreen/constants/appcolors.dart';

class CelebrationWidget extends StatefulWidget {
  final int badgeCondition; // 넘겨받은 조건 (ex. 1 2 3 ... )

  const CelebrationWidget({super.key, required this.badgeCondition});

  @override
  _CelebrationWidgetState createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget> {
  late ConfettiController _controllerCenter;

  // 조건에 따라 메시지와 이미지를 매핑
  final Map<int, Map<String, String>> _badgeData = {
    1: {
      'message': '행운만땅',
      'image': 'assets/images/badge.png',
    },
    2: {
      'message': '걷기 챔피언',
      'image': 'assets/images/trophy.png',
    },
    3: {
      'message': '티끌모아 태산',
      'image': 'assets/images/coinpig.png',
    },
    // 다른 조건도 추가 가능
  };

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 2));
    _controllerCenter.play(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 조건에 맞는 메시지와 이미지 불러오기
    final badgeInfo = _badgeData[widget.badgeCondition]!;
    final badgeMessage = badgeInfo['message']!;
    final badgeImage = badgeInfo['image']!;

    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _controllerCenter,
          blastDirectionality: BlastDirectionality.explosive, // 모든 방향으로 터짐
          emissionFrequency: 0.04, // 컨페티가 더 자주 나오게 설정
          numberOfParticles: 80, // 더 많은 양의 컨페티
          shouldLoop: false,
          colors: const [
            Color.fromARGB(255, 244, 158, 186),
            AppColors.green,
            Color.fromARGB(255, 240, 160, 254),
            Color.fromARGB(255, 254, 255, 177),
            Color.fromARGB(255, 249, 118, 118),
            Color.fromARGB(255, 143, 181, 253),
            Color.fromARGB(255, 170, 153, 247),
          ], // 파티클 색상
        ),
        Dialog(
          backgroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  badgeImage, // 매핑된 이미지 경로
                  width: 100,
                  height: 170,
                ),
                const SizedBox(height: 10),
                const Text('축하합니다!',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('"$badgeMessage"를 획득하셨습니다!'),
                const SizedBox(height: 24),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인',
                        style: TextStyle(fontSize: 16, color: Colors.white))),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
