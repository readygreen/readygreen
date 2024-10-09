import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  // Example data structure for notices
  final List<Map<String, dynamic>> notices = [
    {
      'title': '[안내] 창립 10주년 기념 - 다섯번째, 100억 기금 \'빛썸 나눔 공익재단\' 출범',
      'date': '2023.12.01',
      'is_important': true,
    },
    {
      'title': '[안내] 창립 10주년 기념 - 네번째, \'더욱 투명하게\' 오픈 경영 선포',
      'date': '2023.11.13',
      'is_important': false,
    },
    {
      'title': '[안내] 빛썸 임직원 사칭 주의 안내',
      'date': '2023.07.28',
      'is_important': false,
    },
    {
      'title': '[안내] 빛썸 이용약관 개정 안내',
      'date': '2023.12.19',
      'is_important': true,
    },
    {
      'title': '[이벤트] 퓨저니스트(ACE) 원화 마켓 추가 기념 에어드랍 이벤트',
      'date': '2023.12.18',
      'is_important': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice'),
      ),
      body: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          final bool isImportant = notice['is_important'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isImportant ? Colors.yellow[100] : Colors.white,
                border: Border.all(
                  color: isImportant ? Colors.redAccent : Colors.grey[300]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isImportant ? Colors.red : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    notice['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
