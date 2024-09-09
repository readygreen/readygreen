import 'package:flutter/material.dart';
import 'package:readygreen/widgets/common/button.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/bottom_navigation.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: SingleChildScrollView(
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
        ),
        bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
