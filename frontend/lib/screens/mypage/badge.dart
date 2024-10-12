import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/common/badgecong.dart';

class BadgePage extends StatefulWidget {
  const BadgePage({super.key});

  @override
  _BadgePageState createState() => _BadgePageState();
}

class BadgeDTO {
  final String title;
  final String subtitle;
  final String image;
  bool hasBadge;

  BadgeDTO({
    required this.title,
    required this.subtitle,
    required this.image,
    this.hasBadge = false,
  });
}

class _BadgePageState extends State<BadgePage> {
  // 대표 뱃지의 초기값
  List<BadgeDTO> badges = [
    BadgeDTO(
      title: '언제그린 가족',
      subtitle: '회원 가입을 축하해요',
      image: 'assets/images/signupcong.png',
      hasBadge: true,
    ),
    BadgeDTO(
      title: '행운 만땅',
      subtitle: '행운이 가득해요',
      image: 'assets/images/badge.png',
      hasBadge: false,
    ),
    BadgeDTO(
      title: '걷기 챔피언',
      subtitle: '하루 동안 10,000보 이상 걸었어요',
      image: 'assets/images/trophy.png',
      hasBadge: false,
    ),
    BadgeDTO(
      title: '티끌모아 태산',
      subtitle: '10,000포인트 달성했어요',
      image: 'assets/images/coinpig.png',
      hasBadge: false,
    ),
  ];
  final NewUserApi newUserApi = NewUserApi();
  final storage = const FlutterSecureStorage();
  String? fortune = "";
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _fetchBadgeInfo();
    _fetchGetBadge();
  }

  Future<void> _fetchGetBadge() async {
    fortune = await storage.read(key: 'fortune');
    print("Badge 정보 가져오기 시작");

    // badges 리스트를 순회
    for (int i = 1; i < badges.length; i++) {
      BadgeDTO badge = badges[i];
      if (!badge.hasBadge) {
        if (i == 1) {
          print("fortune");
          print(fortune);
          if (fortune != "111" && fortune != "") {
            print(fortune);
            if (await newUserApi.postBadgeFortune()) {
              _showCelebration(i);
              _fetchBadgeInfo();
              break;
            }
          }
        } else if (i == 2) {
          if (await newUserApi.postBadgeStep()) {
            _showCelebration(i);
            _fetchBadgeInfo();
            break;
          }
        } else if (i == 3) {
          if (await newUserApi.postBadgePoint()) {
            _showCelebration(i);
            _fetchBadgeInfo();
            break;
          }
        }
      }
    }
    print("Badge 정보 가져오기 완료");
  }

  Future<void> _fetchBadgeInfo() async {
    Map<String, dynamic>? fetchedBadge = await newUserApi.getBadge();
    if (fetchedBadge != null && fetchedBadge['type'] is String) {
      String badgeTypes = fetchedBadge['type']; // 문자열로 되어 있는 type 값

      setState(() {
        selectedIndex = fetchedBadge['title'];
        // badgeTypes 문자열에서 각 문자를 가져와 hasBadge 값을 업데이트
        for (int i = 0; i < badgeTypes.length; i++) {
          if (i < badges.length) {
            if (badgeTypes[i] == '1') {
              badges[i + 1].hasBadge = true;
            } else {
              badges[i + 1].hasBadge = false;
            }
          }
        }
      });
    }
  }

  Future<void> _editBadge(int index) async {
    newUserApi.postBadge(index);
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 전체 여백 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
                        '나만의 뱃지',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20), // 상단 여백
              // 선택된 뱃지 이미지
              Image.asset(
                badges[selectedIndex].image,
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              // 선택된 뱃지 이름
              Text(
                badges[selectedIndex].title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                  fontFamily: 'LogoFont',
                ),
              ),
              const SizedBox(height: 8),
              // 선택된 뱃지 설명
              Text(
                badges[selectedIndex].subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 25),
              // 배지 리스트
              Column(
                children: badges.asMap().entries.map((entry) {
                  int index = entry.key;
                  BadgeDTO badge = entry.value;
                  return _buildBadgeCard(
                      context, badge.image, badge.title, badge.subtitle, index,
                      hasBadge: badge.hasBadge // 선택 여부 설정
                      );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 배지 카드 빌드 함수
// 배지 카드 빌드 함수
  Widget _buildBadgeCard(
    BuildContext context,
    String imageUrl,
    String title,
    String subtitle,
    int index, {
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (hasBadge) {
          _editBadge(index);
        } else {
          print('배지를 아직 획득하지 못했습니다.');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: hasBadge
              ? Colors.white
              : Colors.grey.withOpacity(0.1), // 배경을 더 부드럽게 흐리게 설정
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: index == selectedIndex && hasBadge
                ? AppColors.green
                : AppColors.grey, // 선택된 카드에 대한 강조 (획득한 경우에만)
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        child: Row(
          children: [
            // 배지 이미지
            Image.asset(
              hasBadge ? imageUrl : 'assets/images/lock.png', // 잠금 상태 이미지
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 16),
            // 배지 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasBadge ? title : '숨겨진 뱃지',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasBadge
                        ? AppColors.green
                        : Colors.grey, // 잠금 상태면 회색 텍스트
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasBadge ? subtitle : '숨겨진 뱃지를 찾아보세요.', // 잠금 상태면 고정된 메시지 표시
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebration(int badgeCondition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CelebrationWidget(badgeCondition: badgeCondition);
      },
    );
  }
}
