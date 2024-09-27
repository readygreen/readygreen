import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/api/main_api.dart';
import 'package:readygreen/widgets/common/textbutton.dart';
import 'package:readygreen/widgets/common/cardbox.dart';
import 'package:readygreen/widgets/common/squarecardbox.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/modals/weather_modal.dart';
import 'package:readygreen/widgets/modals/luck_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final NewMainApi api = NewMainApi();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadAndStoreFortune(); // 페이지가 로드될 때 운세 데이터 로드 및 저장
  }

  // 운세 데이터를 API로부터 가져와서 로컬 스토리지에 저장
  Future<void> _loadAndStoreFortune() async {
    final fortune = await api.getFortune(); // API 요청
    if (fortune != null) {
      await storage.write(key: 'fortune', value: fortune); // 로컬 스토리지에 저장
      // print('운세 저장 완료: $fortune');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
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
                  child: GestureDetector(
                    onTap: () {
                      // 날씨 카드 클릭 시 WeatherModal 모달 띄우기
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const WeatherModal(); // 분리한 WeatherModal 사용
                        },
                      );
                    },
                    child: SquareCardBox(
                      title: '날씨',
                      textColor: Colors.black,
                      imageUrl: 'assets/images/w-sun.png',
                      backgroundGradient: LinearGradient(
                        colors: [AppColors.weaherblue, AppColors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      subtitle: '맑음',
                      subtitleColor: AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const FortuneModal();
                        },
                      );
                    },
                    child: SquareCardBox(
                      title: '오늘의운세',
                      backgroundColor: AppColors.darkblue,
                      textColor: AppColors.white,
                      imageUrl: 'assets/images/luck.png',
                    ),
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
