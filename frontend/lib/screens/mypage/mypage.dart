import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/screens/mypage/badge.dart';
import 'package:readygreen/screens/mypage/feedback.dart';
import 'package:readygreen/screens/mypage/feedback_list.dart';
// import 'package:readygreen/screens/mypage/myBadge.dart';
import 'package:readygreen/screens/mypage/myPlace.dart';
import 'package:readygreen/screens/mypage/watch.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/modals/birth_modal.dart';
import 'package:readygreen/widgets/mypage/cardbox_mypage.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/screens/mypage/notice.dart';
import 'package:readygreen/widgets/mypage/squarecard_mypage.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final NewUserApi userApi = NewUserApi();
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  int title = 0;

  @override
  void initState() {
    super.initState();
    _getProfile();
    _getTitleBadge();
  }

  Future<void> _getProfile() async {
    final data = await userApi.getProfile();
    if (mounted) {
      setState(() {
        profileData = data;
        isLoading = false; // 데이터 로딩 완료
        // print('Profile Image URL: ${profileData?['profileImg']}');
      });
    }
  }

  Future<void> _getTitleBadge() async {
    final data = await userApi.getBadgeTitle();
    if (mounted) {
      setState(() {
        title = data;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 저장된 모든 키-값 쌍을 가져오기
    Map<String, String> allValues = await storage.readAll();

    // 'fortuneDate'를 제외한 나머지 키들 삭제
    allValues.remove('fortuneDate'); // 'fortuneDate' 삭제되지 않게 제거
    allValues.remove('fortune');

    // 남은 키들을 삭제
    for (String key in allValues.keys) {
      await storage.delete(key: key);
    }

    // 로그아웃 후 로그인 페이지로 이동
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // 로그인 화면 경로
        (Route<dynamic> route) => false, // 이전 페이지 스택 제거
      );
    }
  }

  Future<void> _openBirthModal() async {
    // 모달에서 생일이 성공적으로 업데이트된 경우 true를 반환받도록 처리
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const BirthModal();
      },
    );

    // 모달이 닫히고 나면 프로필 새로고침 (result가 true일 때)
    if (result != null) {
      await _getProfile();
    }
  }

  String _getBadge(int title) {
    if (title == 0) {
      return "assets/images/signupcong.png";
    } else if (title == 1) {
      return "assets/images/badge.png";
    } else if (title == 2) {
      return "assets/images/trophy.png";
    } else if (title == 3) {
      return "assets/images/coinpig.png";
    } else {
      return "assets/images/default.png"; // 예외적인 경우 기본 이미지를 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BackgroundContainer(
          child: isLoading
              ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // 프로필 정보
                    CardBox(
                      title: '내 정보',
                      height: 150,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      child: Row(
                        children: [
                          // 프로필 이미지
                          CircleAvatar(
                            radius: 35,
                            backgroundImage:
                                (profileData?['profileImg'] != null &&
                                        profileData?['profileImg']!.isNotEmpty)
                                    ? NetworkImage(profileData!['profileImg'])
                                        as ImageProvider
                                    : const AssetImage(
                                        'assets/images/user.png'), // 기본 이미지 설정
                            onBackgroundImageError: (error, stackTrace) {
                              print('Failed to load profile image: $error');
                            },
                          ),
                          const SizedBox(width: 13),
                          // 프로필 텍스트 정보
                          _buildProfileSection(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 내 배지 및 내 장소
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // 페이지 이동을 위한 네비게이션
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BadgePage(), // 이동할 페이지
                                ),
                              );
                              if (result != null) {
                                print(result);
                                setState(() {
                                  title = result;
                                });
                              }
                            },
                            child: SquareCardMypage(
                              title: '내 배지',
                              imageUrl: _getBadge(title),
                              subtitle: '설정하기',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyPlacePage()), // PlacePage로 이동
                              );
                            },
                            child: const SquareCardMypage(
                              title: '내 장소',
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              imageUrl: 'assets/images/place.png',
                              subtitle: '상세보기',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 고객지원 섹션
                    _buildSupportSection(),
                    const SizedBox(height: 16),
                    // 계정 설정 섹션
                    _buildSettingsSection(),
                  ],
                ),
        ),
      ),
    );
  }

  // 프로필 텍스트 부분
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              '        이름',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              profileData?['nickname'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '     이메일',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              profileData?['email'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              ' 생년월일',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  profileData?['birth'] ?? '생일을 등록해주세요',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: _openBirthModal,
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 고객지원 섹션
  Widget _buildSupportSection() {
    return CardboxMypage(
      title: const Row(
        children: [
          Icon(Icons.feedback_rounded, size: 20, color: AppColors.red),
          SizedBox(width: 8),
          Text(
            '고객지원',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      height: 180,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoticePage()),
              );
            },
            child: _buildItem('공지사항'),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackPage()),
              );
            },
            child: _buildItem('건의하기'),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackListPage()),
              );
            },
            child: _buildItem('내 건의함'),
          ),
        ],
      ),
    );
  }

  // 계정 설정 섹션
  Widget _buildSettingsSection() {
    return CardboxMypage(
      title: const Row(
        children: [
          Icon(Icons.settings_rounded,
              size: 20, color: AppColors.greytext), // 설정 아이콘 추가
          SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
          Text(
            '계정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      height: 180,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WatchPage()),
              );
            },
            child: _buildItem('워치 연결'),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              _handleLogout(context); // 로그아웃 함수 호출
            },
            child: _buildItem('로그아웃'),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              _showDeleteConfirmationDialog(context); // 탈퇴 확인 창 호출
            },
            child: _buildItem('회원탈퇴'),
          ),
        ],
      ),
    );
  }

  // 공통 스타일링된 지원 항목 빌더
  Widget _buildItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Text(title,
          style: const TextStyle(fontSize: 16, color: AppColors.greytext)),
    );
  }

  // 탈퇴 알림창
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다른 곳을 눌러도 창이 닫히지 않게 설정
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 모서리를 둥글게
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '회원탈퇴',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "LogoFont"), // 큰 제목 스타일
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '정말 탈퇴하시겠습니까?\n\n회원 정보 및 포인트 등 \n모든 내역이 삭제됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16), // 본문 스타일
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // 버튼 간격 맞추기
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red, // 확인 버튼 색상
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 10), // 버튼 패딩
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15), // 모서리 둥글게
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop(); // 모달 닫기
                            await userApi.deleteUser(); // 탈퇴 API 호출
                            if (mounted) {
                              _handleLogout(context); // 로그아웃 처리
                            }
                          },
                          child: const Text(
                            '확인',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.white), // 확인 버튼 텍스트
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // 취소 버튼 색상
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 10), // 버튼 패딩
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15), // 모서리 둥글게
                            ),
                          ),
                          onPressed: () {
                            if (mounted) {
                              Navigator.of(context).pop(); // 모달 닫기
                            }
                          },
                          child: const Text(
                            '취소',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.white), // 취소 버튼 텍스트
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
