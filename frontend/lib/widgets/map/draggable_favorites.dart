import 'package:flutter/material.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:readygreen/screens/map/map.dart';
import 'package:readygreen/widgets/common/textbutton.dart';

class DraggableFavorites extends StatefulWidget {
  final ScrollController scrollController;
  const DraggableFavorites({super.key, required this.scrollController});

  @override
  _DraggableFavoritesState createState() => _DraggableFavoritesState();
}

class _DraggableFavoritesState extends State<DraggableFavorites> {
  List<BookmarkDTO> _bookmarks = [];
  final MapStartAPI mapStartAPI = MapStartAPI();

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    final bookmarksData = await mapStartAPI.fetchBookmarks();

    if (bookmarksData != null) {
      print("데이터");
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
    return DraggableScrollableSheet(
      initialChildSize: 0.04,
      minChildSize: 0.04, // 최소 높이
      maxChildSize: 0.85, // 최대 높이
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 인디케이터
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              // 즐겨찾기 목록
              Expanded(
                child: _bookmarks.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController, // 스크롤 가능 설정
                        itemCount: _bookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = _bookmarks[index];
                          return ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(bookmark.destinationName),
                            trailing: CustomButton(),
                          );
                        },
                      )
                    : const Center(
                        child: Text('즐겨찾기가 없습니다.'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
