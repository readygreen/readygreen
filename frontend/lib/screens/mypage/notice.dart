import 'package:flutter/material.dart';
import 'package:readygreen/api/notice_api.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final NoticeApi noticeApi = NoticeApi();
  List<Map<String, dynamic>> notices = [];
  int? expandedIndex; // 클릭된 항목의 인덱스 저장

  @override
  void initState() {
    super.initState();
    fetchNotices(); // 공지사항 데이터 불러오기
  }

  Future<void> fetchNotices() async {
    List<dynamic>? fetchedNotices = await noticeApi.fetchNoticeData(); // 비동기 호출
    if (fetchedNotices != null) {
      setState(() {
        notices = List<Map<String, dynamic>>.from(fetchedNotices);
        print(notices); // 데이터를 확인하기 위한 로그 출력
      });
    } else {
      print('공지사항 데이터를 가져오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BgcontainerMypage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        '공지사항',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              notices.isNotEmpty // notices가 비어 있지 않으면 ListView.builder를 보여줌
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling within the list
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final notice = notices[index];
                        final bool isImportant = notice['important'] ?? false;

                        // 클릭된 항목인지 확인 (확장할지 여부)
                        bool isExpanded = expandedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              // 같은 항목을 다시 클릭하면 닫힘, 다른 항목을 클릭하면 해당 항목 확장
                              expandedIndex = expandedIndex == index ? null : index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300), // 애니메이션 효과
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white, // 하얀색 박스 배경
                                border: Border.all(
                                  color: isImportant ? Colors.redAccent : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.grey.withOpacity(0.5),
                                //     spreadRadius: 2,
                                //     blurRadius: 5,
                                //     offset: Offset(0, 3), // 그림자 위치 조정
                                //   ),
                                // ],
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
                                      maxLines: isExpanded ? null : 1, // 확장되면 전체 보여주고, 아니면 1줄로 제한
                                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 확장되면 overflow 처리 해제 // 넘치는 텍스트를 "..."로 표시
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    notice['createDate'].substring(0, 10), // 날짜 형식
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '작성자: ${notice['author']}', // 작성자 정보
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${notice['content']}', // 공지사항 내용
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: CircularProgressIndicator(), // 데이터를 로드 중일 때 로딩 스피너 표시
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
