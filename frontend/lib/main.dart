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
              horizontal: 20,
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
                  height: 5,
                ),
                Row(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SquareCardBox(
                      title: '날씨',
                      height: 170,
                    ),
                    SquareCardBox(
                      title: '운세',
                      height: 170,
                      backgroundColor: Color(0xFF2D3765),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                CardBox(title: '자주가는목적지', height: 180),
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
                  title: '현재 위치 ㅇㅇ동 장소 추천',
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      text: 'Transfer',
                      bgColor: Color(0xFFF1B33B),
                      textColor: Colors.black,
                    ),
                    Button(
                      text: 'Request',
                      bgColor: Color(0xFF1F2123),
                      textColor: Colors.white,
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
