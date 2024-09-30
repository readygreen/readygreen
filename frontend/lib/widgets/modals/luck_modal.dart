import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/appcolors.dart';

class FortuneModal extends StatefulWidget {
  const FortuneModal({Key? key}) : super(key: key);

  @override
  _FortuneModalState createState() => _FortuneModalState();
}

class _FortuneModalState extends State<FortuneModal> {
  String fortune = 'Loading...';
  String? fortuneWork;
  String? fortuneLove;
  String? fortuneHealth;
  String? fortuneMoney;
  String? fortuneLuckyNumber;
  String? closingMessage; // 마지막 문장 저장 변수

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadStoreFortune();
  }

  // 로컬 스토리지에서 운세 데이터를 불러오는 함수
  Future<void> _loadStoreFortune() async {
    final storedFortune = await storage.read(key: 'fortune'); // 저장된 운세 불러오기
    print(storedFortune);
    if (storedFortune != null) {
      _parseFortune(storedFortune); // 파싱 함수 호출
    } else {
      setState(() {
        fortune = '운세 정보를 불러올 수 없습니다.';
      });
    }
  }

  // 운세 데이터를 카테고리별로 파싱하는 함수
  void _parseFortune(String fortuneText) {
    final RegExp workExp = RegExp(r'일:\s*([^\n]+)');
    final RegExp loveExp = RegExp(r'사랑:\s*([^\n]+)');
    final RegExp healthExp = RegExp(r'건강:\s*([^\n]+)');
    final RegExp moneyExp = RegExp(r'금전:\s*([^\n]+)');
    final RegExp luckyNumberExp = RegExp(r'행운의 숫자:\s*([^\n]+)');

    setState(() {
      fortuneWork = workExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneLove = loveExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneHealth = healthExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneMoney = moneyExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneLuckyNumber =
          luckyNumberExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';

      // 마지막 줄을 추출하는 로직
      List<String> lines = fortuneText.trim().split('\n');
      closingMessage = lines.isNotEmpty ? lines.last : '긍정적인 하루를 보내세요!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            width: deviceWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 상단 제목
                const Text(
                  '오늘의 운세',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple,
                    fontFamily: 'LogoFont',
                  ),
                ),
                const SizedBox(height: 16),

                // 중간 이미지
                Image.asset(
                  'assets/images/fortune.png',
                  height: 170,
                ),
                const SizedBox(height: 30),

                // 운세 내용 텍스트 (카테고리별로 구분)
                _buildFortuneItem('  일 💻', fortuneWork ?? '내용 없음'),
                const SizedBox(height: 10),
                _buildFortuneItem('사랑💕', fortuneLove ?? '내용 없음'),
                const SizedBox(height: 10),
                _buildFortuneItem('건강💪', fortuneHealth ?? '내용 없음'),
                const SizedBox(height: 10),
                _buildFortuneItem('금전💵', fortuneMoney ?? '내용 없음'),
                const SizedBox(height: 10),
                _buildFortuneItem('행운의 숫자 🍀', fortuneLuckyNumber ?? '내용 없음'),

                const SizedBox(height: 16),

                // 마지막 문장 출력
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    closingMessage ?? '행운이 가득한 하루 보내세요!',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // const SizedBox(height: 16),
              ],
            ),
          ),
          // 닫기 버튼
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 30,
                color: AppColors.greytext,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리와 운세 내용을 구분해서 출력하는 위젯
  Widget _buildFortuneItem(String category, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$category    ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
