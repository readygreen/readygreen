import 'package:flutter/material.dart';
import 'package:readygreen/api/pointStep_api.dart';
import 'package:readygreen/constants/appcolors.dart';

class PointDetailPage extends StatefulWidget {
  @override
  _PointDetailPageState createState() => _PointDetailPageState();
}

class _PointDetailPageState extends State<PointDetailPage> {
  final PointstepApi pointstepApi = PointstepApi();
  Map<String, List<Map<String, dynamic>>> pointDays = {};
  String totalPoint = '0'; // 타입 수정

  @override
  void initState() {
    super.initState();
    _getPointList();
  }

  void _getPointList() async {
    Map<String, List<Map<String, dynamic>>> points =
        await pointstepApi.fetchPointList();
    String fetchedPoint = await pointstepApi.fetchPoint();
    setState(() {
      pointDays = points;
      totalPoint = fetchedPoint as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greybg, // 전체 배경색
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 23.0, right: 23.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 포인트 및 버튼
            _buildHeader(context),
            // const SizedBox(height: 5),
            // 거래 내역
            Expanded(
              child: ListView(
                children: [
                  for (var entry in pointDays.entries) // Map의 엔트리 반복
                    _pointPerDay(
                        entry.key,
                        entry
                            .value), // entry.value의 타입이 List<Map<String, dynamic>>이므로 잘 작동
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 헤더 구성
  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), // 패딩 추가
      child: Row(
        children: [
          const SizedBox(width: 16), // 이미지와 텍스트 사이의 간격
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로로 가운데 정렬
              crossAxisAlignment: CrossAxisAlignment.center, // 가로로 가운데 정렬
              children: [
                Text(
                  '${totalPoint} 포인트',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // 버튼 클릭 시 처리 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppColors.green, width: 1),
                    ),
                    elevation: 0, // 그림자 효과 제거
                  ),
                  child: Text(
                    '전환하기',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/coins.png',
            width: 150,
            height: 150,
          ),
        ],
      ),
    );
  }

  Widget _pointPerDay(String date, List<Map<String, dynamic>> points) {
    return Container(
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 4.0), // 패딩 추가
      margin: const EdgeInsets.only(bottom: 20.0), // 하단에 마진 추가
      decoration: BoxDecoration(
        color: Colors.white, // 배경색을 여기에 설정
        borderRadius: BorderRadius.circular(16), // 모서리 둥글게
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Text(
            date, // 날짜 표시
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10), // 날짜와 포인트 리스트 사이의 간격
          // 포인트 리스트 출력
          for (var point in points.reversed)
            _buildTransactionItem(
                point['description'], point['point'].toString()),
          // 포인트 아이템 출력
        ],
      ),
    );
  }

  // 거래 내역 아이템 구성
  Widget _buildTransactionItem(String description, String point) {
    // 첫 번째 단어 추출
    String firstWord = description.split(' ').first;

    // 이미지 경로 결정
    String imagePath;
    if (firstWord == '걸음수') {
      imagePath = 'assets/images/foot.png'; // 걸음수일 때 사용할 이미지
    } else if (firstWord == '운세') {
      imagePath = 'assets/images/star.png'; // 운세일 때 사용할 이미지
    } else {
      imagePath = 'assets/images/rainbow.png'; // 기본 이미지 (필요시)
    }

    return Container(
      // 카드가 아닌 컨테이너 사용
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          // 상단에 가로 줄 추가
          Container(
            height: 1, // 줄의 높이
            color: Colors.grey.withOpacity(0.2), // 줄 색상
            margin: const EdgeInsets.only(bottom: 8), // 줄과 텍스트 사이의 간격
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 왼쪽에 이미지 추가
                    Image.asset(
                      imagePath, // 결정된 이미지 경로
                      width: 70, // 이미지의 너비
                      height: 70, // 이미지의 높이
                    ),
                    const SizedBox(width: 25), // 이미지와 텍스트 사이의 간격 (마진 추가)
                    Text(
                      description
                          .split(' ')
                          .skip(1)
                          .join(' '), // 첫 번째 단어 제외하고 출력
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.greytext),
                    ),
                  ],
                ),
                Text(
                  '+${point}P',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
