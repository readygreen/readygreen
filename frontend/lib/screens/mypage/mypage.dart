import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/screens/mypage/feedback.dart';
import 'package:readygreen/screens/mypage/feedback_list.dart';
import 'package:readygreen/screens/mypage/watch.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/mypage/cardbox_mypage.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/screens/mypage/notice.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final NewUserApi userApi = NewUserApi();
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    final data = await userApi.getProfile();
    setState(() {
      profileData = data;
      isLoading = false; // 데이터 로딩 완료
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 저장된 토큰 삭제
    await storage.delete(key: 'accessToken');
    await storage.deleteAll();
    await storage.deleteAll();

    // 로그아웃 후 로그인 페이지로 이동
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // 로그인 화면 경로
      (Route<dynamic> route) => false, // 이전 페이지 스택 제거
    );
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
                      height: 160,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      child: Row(
                        children: [
                          // 프로필 이미지
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: profileData?['profileImageUrl'] !=
                                    null
                                ? NetworkImage(profileData!['profileImageUrl'])
                                : const AssetImage('assets/images/user.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 13),
                          // 프로필 텍스트 정보
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '이름: ${profileData?['nickname'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('이메일: ${profileData?['email'] ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 14)),
                              Text(
                                  '생년월일: ${profileData?['birth'] ?? '생일을 등록해주세요'}',
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 내 배지 및 내 장소
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SquareCardBox(
                            title: '내 배지',
                            imageUrl: 'assets/images/badge.png',
                            subtitle: '설정하기',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SquareCardBox(
                            title: '내 장소',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            imageUrl: 'assets/images/place.png',
                            subtitle: '상세보기',
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

// 고객지원 섹션
  Widget _buildSupportSection() {
    return CardboxMypage(
      title: Row(
        children: [
          Icon(Icons.feedback_rounded, size: 20, color: AppColors.red),
          const SizedBox(width: 8),
          const Text(
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
      title: Row(
        children: [
          Icon(Icons.settings_rounded,
              size: 20, color: AppColors.greytext), // 설정 아이콘 추가
          const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
          const Text(
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
            onTap: () {},
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
}
