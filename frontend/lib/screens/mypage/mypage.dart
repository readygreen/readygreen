import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/theme/appcolors.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  // FlutterSecureStorage 인스턴스 생성
  final storage = const FlutterSecureStorage();

  // 로그아웃 처리 함수
  Future<void> _handleLogout(BuildContext context) async {
    // 저장된 로그인 토큰 삭제
    await storage.delete(key: 'auth_token'); // 'auth_token' 키로 저장된 토큰 삭제

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // 로그인 화면 경로로 이동
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BackgroundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // 프로필 정보 섹션
              CardBox(
                title: '프로필 정보',
                height: 160,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(width: 16),
                    Text('이름: 차유림',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('이메일: c4526@naver.com',
                        style: TextStyle(fontSize: 16)),
                    Text('생년월일: 1999. 10. 25', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 내 배지 및 내 장소 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SquareCardBox(
                      title: '내 배지',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      imageUrl: 'assets/images/badge.png', // 이미지 경로 수정
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SquareCardBox(
                      title: '내 장소',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      imageUrl: 'assets/images/place.png', // 이미지 경로 수정
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 고객지원 섹션

              CardBox(
                title: '고객지원',
                height: 205, // 적절한 크기 조정
                backgroundColor: Colors.white,
                textColor: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSupportItem('공지사항'),
                    _buildSupportItem('건의하기'),
                    _buildSupportItem('내 건의함'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 로그아웃 및 회원탈퇴 섹션
              CardBox(
                title: '설정',
                height: 130,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _handleLogout(context); // 로그아웃 함수 호출
                      },
                      child: const Text('로그아웃', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    const Text('회원탈퇴',
                        style: TextStyle(fontSize: 16, color: AppColors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 고객지원 항목 빌드
  Widget _buildSupportItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }
}
