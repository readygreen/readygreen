import 'package:flutter/material.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/map/map.dart';

class MyPlacePage extends StatefulWidget {
  const MyPlacePage({Key? key}) : super(key: key);

  @override
  _MyPlacePageState createState() => _MyPlacePageState();
}

class _MyPlacePageState extends State<MyPlacePage> {
  final MapStartAPI mapStartAPI = MapStartAPI();
  List<BookmarkDTO> _bookmarks = []; // 실제 데이터

  @override
  void initState() {
    super.initState();
    _fetchBookmarks(); // 북마크 데이터 불러오기
  }

  // 북마크 데이터를 API로부터 가져오는 함수
  Future<void> _fetchBookmarks() async {
    final bookmarksData = await mapStartAPI.fetchBookmarks();
    if (bookmarksData != null) {
      // 북마크 데이터를 BookmarkDTO 리스트로 변환
      List<BookmarkDTO> fetchedBookmarks = bookmarksData.map<BookmarkDTO>((bookmark) {
        return BookmarkDTO(
          id: bookmark['id'],
          name: bookmark['name'],
          destinationName: bookmark['destinationName'],
          latitude: bookmark['latitude'],
          longitude: bookmark['longitude'],
          placeId: bookmark['placeId'],
        );
      }).toList();

      // 변환한 데이터를 상태에 저장
      setState(() {
        _bookmarks = fetchedBookmarks;
      });
    } else {
      print('북마크 데이터를 불러오지 못했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주가는 목적지'),
        backgroundColor: AppColors.white, 
      ),
      backgroundColor: AppColors.white, // 배경색 회색으로 설정
      body: _bookmarks.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 데이터 로딩 중
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return Column(
                  children: [
                    const Divider(thickness: 1), // 첫 번째 항목을 제외한 항목 위에 가로선 추가
                    _buildPlaceItem(
                      context,
                      bookmark.name, // 실제 데이터의 이름 사용
                      bookmark.destinationName, // 목적지 이름
                      Icons.place,
                      bookmark.id 
                    ),
                  ],
                );
              },
            ),
    );
  }

  // 장소 아이템 빌드 함수
  Widget _buildPlaceItem(BuildContext context, String title, String placeName, IconData icon, int id) {
    return ListTile(
      leading: title=="기타"? Icon(Icons.favorite, size: 35, color: Colors.green) : title=="집"? Icon(Icons.home, size: 35, color: Colors.orange) : Icon(Icons.business, size: 35, color: Colors.blue),
      title: Text(
        placeName.contains('대전광역시') 
          ? placeName.substring(placeName.indexOf('대전광역시') + '대전광역시'.length) 
          : placeName, 
        overflow: TextOverflow.ellipsis, // 글자가 길면 말줄임표(...) 처리
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(size:20,Icons.edit),
            onPressed: () {
              _showEditModal(context, title, placeName, id);
            },
          ),
          IconButton(
            icon: const Icon(size:20,Icons.delete),
            onPressed: () {
              _showDeleteModal(context, placeName, id);
            },
          ),
        ],
      ),
    );
  }

   // 수정 모달
  void _showEditModal(BuildContext context, String title, String placeName, int id) {
    // 선택된 인덱스를 외부에서 관리
    int selectedIndex = -1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // 상태를 관리하기 위한 StatefulBuilder 사용
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 모달의 모서리 둥글게
              ),
              child: Container(
                padding: const EdgeInsets.all(16), // 모달 내부에 패딩 추가
                width: MediaQuery.of(context).size.width * 0.9, // 모달 너비를 화면의 90%로 설정
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    // "즐겨찾기 수정" 텍스트 추가
                    const Text(
                      '즐겨찾기 수정',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20), // 텍스트와 아이콘 간의 간격
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0; // 집 선택
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150), // 애니메이션 시간 설정
                              child: selectedIndex == 0
                                  ? Container(
                                      key: const ValueKey<int>(0), // 유니크한 키 필요
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300], // 선택된 경우 배경색
                                        shape: BoxShape.circle, // 원형 배경
                                      ),
                                      child: const Icon(
                                        Icons.home,
                                        size: 50,
                                        color: Colors.orange, // 아이콘 색상 유지
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey<int>(1),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent, // 선택되지 않은 경우
                                        shape: BoxShape.circle, // 원형 배경
                                      ),
                                      child: const Icon(
                                        Icons.home,
                                        size: 50,
                                        color: Colors.orange, // 아이콘 색상 유지
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '집',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1; // 회사 선택
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: selectedIndex == 1
                                  ? Container(
                                      key: const ValueKey<int>(2),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300], // 선택된 경우 배경색
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.business,
                                        size: 50,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey<int>(3),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent, // 선택되지 않은 경우
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.business,
                                        size: 50,
                                        color: Colors.blue,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '회사',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 2; // 기타 선택
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: selectedIndex == 2
                                  ? Container(
                                      key: const ValueKey<int>(4),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey<int>(5),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent, // 선택되지 않은 경우
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '기타',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 35), // 아이콘과 버튼 사이 간격
                    Align(
                      alignment: Alignment.center, // 버튼을 가운데로 정렬
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await mapStartAPI.updateBookmarkType(id, selectedIndex);
                          await _fetchBookmarks();
                          Navigator.pop(context);
                          _showResultModal(context, success ? '수정 성공' : '수정 실패');
                        },
                        child: const Text('수정하기'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.green, // 버튼 색상
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 버튼 모서리를 둥글게
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


// 삭제 모달
  void _showDeleteModal(BuildContext context, String placeName, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 모달의 모서리를 둥글게
              ),
              child: Stack(
                alignment: Alignment.topRight, // x 버튼을 오른쪽 상단에 배치
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0), // 내부 패딩 추가
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center, // 좌우 가운데 정렬
                      children: [
                        const SizedBox(height: 16), // x 버튼 아래 간격
                        const Text(
                          '즐겨찾기 삭제',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // 텍스트 가운데 정렬
                        ),
                        const SizedBox(height: 16), // 제목과 내용 간 간격
                        const Text(
                          '이 장소를 자주 가는 목적지에서 \n삭제하시겠습니까?',
                          textAlign: TextAlign.center, // 텍스트 가운데 정렬
                        ),
                        const SizedBox(height: 32), // 내용과 버튼 간 간격
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success = await mapStartAPI.deleteBookmark(id);
                              await _fetchBookmarks();
                              Navigator.pop(context);
                              _showResultModal(context, success ? '삭제 성공' : '삭제 실패');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // 빨간색 배경
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                              ),
                            ),
                            child: const Text(
                              '삭제하기',
                              style: TextStyle(color: Colors.white), // 흰색 텍스트
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey), // 회색 x 버튼
                    onPressed: () {
                      Navigator.pop(context); // x 버튼 클릭 시 모달 닫기
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

void _showResultModal(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 모서리 둥글게
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 패딩 추가로 디자인 개선
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 추가로 성공/실패 시 시각적 요소 제공
              Icon(
                message == '수정 성공' || message == '삭제 성공'
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: message == '수정 성공' || message == '삭제 성공'
                    ? AppColors.green
                    : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16), // 간격 추가
              Text(
                message,
                style: const TextStyle(
                  fontSize: 22, // 텍스트 크기 약간 줄임
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // 텍스트 색상 변경
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // 텍스트와 버튼 사이에 간격 추가
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 모달 닫기
                },
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white, // 버튼 텍스트 하얀색
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: AppColors.green, // 버튼 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
                  ),
                  elevation: 4, // 버튼에 그림자 추가
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  // 아이콘 빌드 함수
  Widget _buildIconOption(BuildContext context, int selectedIndex, int index, IconData icon, Color color, String label, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: selectedIndex == index
                ? Container(
                    key: ValueKey<int>(index),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 50,
                      color: color,
                    ),
                  )
                : Container(
                    key: ValueKey<int>(index + 10),
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 50,
                      color: color,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }







}
