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
      List<BookmarkDTO> fetchedBookmarks =
          bookmarksData.map<BookmarkDTO>((bookmark) {
        return BookmarkDTO(
          id: bookmark['id'],
          name: bookmark['name'],
          destinationName: bookmark['destinationName'],
          latitude: bookmark['latitude'],
          longitude: bookmark['longitude'],
          placeId: bookmark['placeId'],
        );
      }).toList();

      // 집 > 회사 > 기타 순으로 정렬
      fetchedBookmarks.sort((a, b) {
        const priority = {'집': 0, '회사': 1, '기타': 2};
        return priority[a.name]!.compareTo(priority[b.name]!);
      });

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0), // AppBar의 높이를 조정
        child: Column(
          children: [
            const SizedBox(height: 30), // 원하는 크기만큼 위에 여백 추가
            AppBar(
              title: const Text(
                '자주가는 목적지',
              ),
              backgroundColor: AppColors.white,
              elevation: 0, // AppBar의 그림자 없애기 (선택 사항)
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.white,
      body: _bookmarks.isEmpty
          ? const Center(
              child: Text(
                '자주 가는 목적지가 등록되지 않았습니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ) // 데이터가 없을 때 출력
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
                        bookmark.placeId,
                        bookmark.id),
                  ],
                );
              },
            ),
    );
  }

  // 장소 아이템 빌드 함수
  Widget _buildPlaceItem(BuildContext context, String title, String placeName,
      IconData icon, String placeId, int id) {
    return ListTile(
      leading: Container(
        width: 50, // 고정된 너비
        height: 50, // 고정된 높이
        decoration: BoxDecoration(
          color: title == "기타"
              ? AppColors.green // 기타일 경우 배경색 설정
              : title == "집"
                  ? AppColors.orange // 집일 경우 배경색 설정
                  : AppColors.bluecompany, // 회사일 경우 배경색 설정
          shape: BoxShape.circle, // 원형 배경 설정
        ),
        child: Align(
          alignment: Alignment.center, // 아이콘을 중앙 정렬
          child: Icon(
            title == "기타"
                ? Icons.favorite_rounded
                : title == "집"
                    ? Icons.home_rounded
                    : Icons.business_rounded,
            size: title == "집" ? 40 : 35, // 집 아이콘만 크기 40, 나머지는 35로 설정
            color: Colors.white, // 아이콘 색상 흰색으로 설정
          ),
        ),
      ),
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
            icon: const Icon(size: 20, Icons.edit),
            onPressed: () {
              _showEditModal(context, title, placeName, id);
            },
          ),
          IconButton(
            icon: const Icon(size: 20, Icons.delete),
            onPressed: () {
              _showDeleteModal(context, placeName, placeId);
            },
          ),
        ],
      ),
    );
  }

  // 수정 모달
  void _showEditModal(
      BuildContext context, String title, String placeName, int id) {
    int selectedIndex = -1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 모달의 모서리 둥글게
              ),
              child: Stack(
                alignment: Alignment.topRight, // x 버튼을 오른쪽 상단에 배치
                children: [
                  Container(
                    padding: const EdgeInsets.all(16), // 모달 내부에 패딩 추가
                    width: MediaQuery.of(context).size.width *
                        0.9, // 모달 너비를 화면의 90%로 설정
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 15),
                        // "즐겨찾기 수정" 텍스트 추가
                        const Text(
                          '즐겨찾기 수정',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'LogoFont'),
                        ),
                        const SizedBox(height: 30), // 텍스트와 아이콘 간의 간격
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
                                  Container(
                                    width: 70, // 고정된 너비 설정
                                    height: 70, // 고정된 높이 설정
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 252, 170, 63), // 기본 배경색
                                      shape: BoxShape.circle, // 원형 배경 설정
                                      border: selectedIndex == 0
                                          ? Border.all(
                                              color: Color.fromARGB(
                                                  255, 255, 208, 100),
                                              width: 5, // 선택된 경우 테두리 추가
                                            )
                                          : Border.all(
                                              color: Colors.transparent),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.home_rounded,
                                        size: 40,
                                        color: Colors.white, // 아이콘 흰색
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '집',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
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
                                  Container(
                                    width: 70, // 고정된 너비 설정
                                    height: 70, // 고정된 높이 설정
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.bluecompany, // 기본 배경색
                                      shape: BoxShape.circle, // 원형 배경 설정
                                      border: selectedIndex == 1
                                          ? Border.all(
                                              color: Color.fromRGBO(
                                                  148, 194, 251, 1),
                                              width: 5,
                                            )
                                          : Border.all(
                                              color: Colors.transparent),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.business_rounded,
                                        size: 40,
                                        color: Colors.white, // 아이콘 흰색
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '회사',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
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
                                  Container(
                                    width: 70, // 고정된 너비 설정
                                    height: 70, // 고정된 높이 설정
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.green, // 기본 배경색
                                      shape: BoxShape.circle, // 원형 배경 설정
                                      border: selectedIndex == 2
                                          ? Border.all(
                                              color: const Color.fromARGB(
                                                  255, 178, 222, 76),
                                              width: 5,
                                            )
                                          : Border.all(
                                              color: Colors.transparent),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 40,
                                        color: Colors.white, // 아이콘 흰색
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '기타',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25), // 아이콘과 버튼 사이 간격
                        Align(
                          alignment: Alignment.center, // 버튼을 가운데로 정렬
                          child: ElevatedButton(
                            onPressed: () async {
                              await mapStartAPI.updateBookmarkType(
                                  id, selectedIndex);
                              await _fetchBookmarks();
                              Navigator.pop(context);
                            },
                            child: const Text('수정하기'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 13),
                              backgroundColor: AppColors.green, // 버튼 색상
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15), // 버튼 모서리를 둥글게
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.grey), // 회색 x 버튼
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

// 삭제 모달
  void _showDeleteModal(
      BuildContext context, String placeName, String placeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
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
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // 좌우 가운데 정렬
                      children: [
                        const SizedBox(height: 16), // x 버튼 아래 간격
                        const Text(
                          '즐겨찾기 삭제',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'LogoFont'),
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
                              // 삭제 로직 추가
                              await mapStartAPI.deleteBookmark(placeId);
                              await _fetchBookmarks();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red, // 빨간색 배경
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15), // 버튼 모서리 둥글게
                              ),
                            ),
                            child: const Text(
                              '삭제하기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold), // 흰색 텍스트
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.grey), // 회색 x 버튼
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
}
