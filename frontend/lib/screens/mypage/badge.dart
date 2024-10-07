import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class BadgePage extends StatefulWidget {
  @override
  _BadgePageState createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
  // 대표 뱃지의 초기값
  String _selectedBadgeTitle = '행운 만땅';
  String _selectedBadgeSubtitle = '행운이 가득해요';
  String _selectedBadgeImage = 'assets/images/badge.png';

  // 뱃지 선택 함수
  void _selectBadge(String title, String subtitle, String imageUrl) {
    setState(() {
      _selectedBadgeTitle = title;
      _selectedBadgeSubtitle = subtitle;
      _selectedBadgeImage = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 전체 여백 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // 상단 여백
              // 선택된 뱃지 이미지
              Image.asset(
                _selectedBadgeImage,
                width: 150,
                height: 150,
              ),
              SizedBox(height: 16),
              // 선택된 뱃지 이름
              Text(
                _selectedBadgeTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                  fontFamily: 'LogoFont',
                ),
              ),
              SizedBox(height: 8),
              // 선택된 뱃지 설명
              Text(
                _selectedBadgeSubtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              // 배지 리스트
              _buildBadgeCard(
                context,
                'assets/images/badge.png',
                '행운 만땅',
                '행운이 가득해요',
              ),
              _buildBadgeCard(
                context,
                'assets/images/trophy.png', // 트로피 이미지 경로
                '걷기 챔피언',
                '하루 동안 10,000보 이상 걸었어요',
              ),

              _buildBadgeCard(
                context,
                'assets/images/coinpig.png', // 코인 이미지 경로
                '티끌모아 태산',
                '10,000포인트 달성했어요',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 배지 카드 빌드 함수
  Widget _buildBadgeCard(
    BuildContext context,
    String imageUrl,
    String title,
    String subtitle, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        _selectBadge(title, subtitle, imageUrl); // 뱃지 선택 시 대표 뱃지 업데이트
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _selectedBadgeTitle == title
                ? AppColors.green
                : AppColors.grey, // 선택된 카드에 대한 강조
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        child: Row(
          children: [
            // 배지 이미지
            Image.asset(
              imageUrl,
              width: 50,
              height: 50,
            ),
            SizedBox(width: 16),
            // 배지 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
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
}
