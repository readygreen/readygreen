import 'package:flutter/material.dart';
import 'package:readygreen/widgets/common/textbutton.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart'; // BackgroundContainer import
import 'package:readygreen/constants/appcolors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 기존 배경색 제거
      body: const MainScreenContent(), // 그냥 MainScreenContent만 출력
    );
  }
}

class MainScreenContent extends StatelessWidget {
  const MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      // 배경 설정을 위한 BackgroundContainer 추가
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '언제그린',
                      style: TextStyle(
                        fontFamily: 'LogoFont',
                        color: AppColors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SquareCardBox(
                    title: '날씨',
                    backgroundColor: AppColors.white,
                    textColor: Colors.black,
                    imageUrl: 'assets/images/badge.png', // 이미지 경로 수정
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SquareCardBox(
                    title: '오늘의운세',
                    backgroundColor: AppColors.darkblue,
                    textColor: AppColors.white,
                    imageUrl: 'assets/images/luck.png', // 이미지 경로 수정
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: const [
                CardBox(title: '자주가는목적지', height: 180),
              ],
            ),
            const SizedBox(height: 16),
            const CardBox(title: '최근 목적지'),
            const SizedBox(height: 16),
            const CardBox(title: '현재 위치 --동 장소 추천'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CustomButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
