import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width; // 기기 너비 가져오기
    double cardSize = deviceWidth / 2.5; // 기기 너비의 반을 카드 크기로 설정
    double largeSize = deviceWidth; // 기기 너비의 반을 카드 크기로 설정

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        // 스크롤 가능하게 설정
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // 유저 정보 섹션
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    // 프로필 이미지
                    // CircleAvatar(
                    //   radius: 40,
                    //   backgroundImage: NetworkImage(
                    //       'https://example.com/profile.jpg'), // 임시 이미지
                    // ),
                    const SizedBox(width: 16),
                    // 이름, 이메일, 생년월일
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('이름: 차유림',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('이메일: c4526@naver.com',
                            style: TextStyle(fontSize: 16)),
                        Text('생년월일: 1999. 10. 25',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 내 배지 및 내 장소 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildCard(
                      icon: Icons.badge,
                      title: '내 배지',
                      subtitle: '행운 만땅',
                      cardSize: cardSize, // 크기 전달
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      icon: Icons.location_on,
                      title: '내 장소',
                      subtitle: '상세보기',
                      cardSize: cardSize, // 크기 전달
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 고객지원 섹션
              _buildSupportSection(largeSize: largeSize),
              const SizedBox(height: 16),
              // 로그아웃 및 회원탈퇴 섹션
              _buildLogoutSection(largeSize: largeSize),
            ],
          ),
        ),
      ),
    );
  }

  // 카드 빌드 메서드
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double cardSize, // cardSize를 인자로 받음
  }) {
    return Container(
      width: cardSize,
      height: cardSize, // width와 height를 동일하게 설정
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 고객지원 섹션
  Widget _buildSupportSection({
    required double largeSize,
  }) {
    return Container(
      width: largeSize,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('고객지원',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSupportItem('공지사항'),
          _buildSupportItem('건의하기'),
          _buildSupportItem('내 건의함'),
        ],
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

  // 로그아웃 섹션
  Widget _buildLogoutSection({required double largeSize}) {
    return Container(
      width: largeSize,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('로그아웃', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('회원탈퇴', style: TextStyle(fontSize: 16, color: Colors.red)),
        ],
      ),
    );
  }
}
