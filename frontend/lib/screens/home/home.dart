import 'package:flutter/material.dart';
import 'package:readygreen/widgets/common/button.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainScreenContent(),
    const Center(child: Text('검색 화면', style: TextStyle(fontSize: 24))),
    const Center(child: Text('설정 화면', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _pages[_selectedIndex],
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class MainScreenContent extends StatelessWidget {
  const MainScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '언제그린',
                      style: TextStyle(
                        color: Color(0xFF7FC818),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SquareCardBox(
                  title: '날씨',
                ),
                SquareCardBox(
                  title: '오늘의 운세',
                  backgroundColor: Color(0xFF2D3765),
                  textColor: Colors.white,
                  imageUrl: 'assets/images/luck.png',
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Column(
              children: [
                CardBox(title: '자주가는목적지', height: 180),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            CardBox(
              title: '최근 목적지',
            ),
            SizedBox(
              height: 15,
            ),
            CardBox(
              title: '현재 위치 --동 장소 추천',
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: '길찾기',
                  borderColor: Color(0xFF7FC818),
                  textColor: Color(0xFF7FC818),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
