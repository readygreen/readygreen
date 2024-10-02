import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/modals/birth_modal.dart';

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
  String? birthdayMessage; // 생일 메시지 변수

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
      // 생일 정보가 없을 경우의 처리
      if (storedFortune.contains('생일 정보가 없습니다')) {
        setState(() {
          birthdayMessage = '생일 정보가 없습니다.';
        });
      } else {
        _parseFortune(storedFortune); // 파싱 함수 호출
      }
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
    final RegExp closingMessageExp = RegExp(r'총운:\s*([^\n]+)');

    setState(() {
      fortuneWork = workExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneLove = loveExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneHealth = healthExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneMoney = moneyExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';
      fortuneLuckyNumber =
          luckyNumberExp.firstMatch(fortuneText)?.group(1) ?? '내용 없음';

      // 총운 값 추출
      closingMessage = closingMessageExp.firstMatch(fortuneText)?.group(1) ??
          '행운이 가득한 하루 보내세요!';
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '오늘의 운세',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple,
                      fontFamily: 'LogoFont',
                    ),
                  ),

                  // 생일 정보가 없는 경우 메시지 표시
                  if (birthdayMessage != null) ...[
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/nobirth.png',
                      height: 170,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      birthdayMessage!,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '이용을 원하시면 생일 등록 후 \n새로고침 해주세요!',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // '등록하러가기' 버튼
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const BirthModal();
                          },
                        );
                      },
                      child: const Text(
                        '등록하러 가기',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ] else ...[
                    const SizedBox(height: 16),
                    // 운세 내용 텍스트 (카테고리별로 구분)
                    Image.asset(
                      'assets/images/fortune.png',
                      height: 170,
                    ),
                    const SizedBox(height: 30),

                    _buildFortuneItem('  일 💻', fortuneWork ?? '내용 없음'),
                    const SizedBox(height: 10),
                    _buildFortuneItem('사랑💕', fortuneLove ?? '내용 없음'),
                    const SizedBox(height: 10),
                    _buildFortuneItem('건강💪', fortuneHealth ?? '내용 없음'),
                    const SizedBox(height: 10),
                    _buildFortuneItem('금전💵', fortuneMoney ?? '내용 없음'),
                    const SizedBox(height: 10),
                    _buildFortuneItem(
                        '행운의 숫자 🍀', fortuneLuckyNumber ?? '내용 없음'),
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
                  ],
                ],
              ),
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
