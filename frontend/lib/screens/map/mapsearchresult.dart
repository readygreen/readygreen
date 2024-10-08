import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:readygreen/widgets/map/mapsearchbackbar.dart';
import 'package:readygreen/widgets/map/placecard.dart';
import 'package:readygreen/screens/map/resultmap.dart';

class BookmarkDTO {
  final int id;
  final String name;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String? alertTime;
  final String placeId;

  BookmarkDTO({
    required this.id,
    required this.name,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    this.alertTime,
    required this.placeId,
  });
}

class MapSearchResultPage extends StatefulWidget {
  final List<Prediction> autoCompleteResults;
  final String searchQuery; // 검색어 추가

  const MapSearchResultPage({
    super.key,
    required this.autoCompleteResults,
    required this.searchQuery, // 검색어 받기
  });

  @override
  _MapSearchResultPageState createState() => _MapSearchResultPageState();
}

class _MapSearchResultPageState extends State<MapSearchResultPage> {
  final MapStartAPI mapStartAPI = MapStartAPI();
  List<BookmarkDTO> _bookmarks = [];
  double? _lat;
  double? _lng;
  String? _placeName;
  String? _address;

  @override
  void initState() {
    super.initState();
    // 초기 검색어를 설정, 없으면 빈 문자열
    print("ㅇㅇㅇㅇㅇㅇ");
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    print("요기요");
    final bookmarksData = await mapStartAPI.fetchBookmarks();
    print("요기요2");
    print(bookmarksData);
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

      // 변환한 데이터를 상태에 저장
      setState(() {
        _bookmarks = fetchedBookmarks;
      });
    } else {
      print('북마크 데이터를 불러오지 못했습니다.');
    }
  }

  // 세부 정보 가져오는 함수
  Future<String> _fetchPlaceDetails(String placeId) async {
    GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');

    if (response.isOkay) {
      final result = response.result;

      print(result.placeId);
      return "${result.name}\n${result.formattedAddress ?? ''}";
    } else {
      return "정보를 가져오지 못했습니다.";
    }
  }

  // 장소가 선택되었을 때 위도, 경도, 장소 이름을 저장하는 함수
  Future<void> _selectPlace(String placeId) async {
    GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');

    if (response.isOkay) {
      final result = response.result;
      setState(() {
        _lat = result.geometry?.location.lat; // null check 추가
        _lng = result.geometry?.location.lng; // null check 추가
        _placeName = result.name;
        _address = result.formattedAddress;
      });
      // 위도, 경도, 장소 이름 출력 (확인용)
      print('위도: $_lat, 경도: $_lng, 장소 이름: $_placeName');

      // 장소 선택 시 resultmap 페이지로 이동하며 위도, 경도, 이름 전달
      if (_lat != null && _lng != null && _placeName != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultMapPage(
              lat: _lat!,
              lng: _lng!,
              placeName: _placeName!,
              address: _address!,
              searchQuery: widget.searchQuery,
              placeId: placeId,
            ),
          ),
        );
      } else {
        print('위치 정보가 없습니다.');
      }
    } else {
      print('장소 선택 실패: ${response.errorMessage}');
    }
  }

  bool _isPlaceBookmarked(String placeId) {
    return _bookmarks.any((bookmark) => bookmark.placeId == placeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 검색 바 배치
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.06,
              left: MediaQuery.of(context).size.width * 0.06,
              right: MediaQuery.of(context).size.width * 0.06,
            ),
            child: MapSearchBackBar(
              placeName: widget.searchQuery, // 초기 선택된 장소 이름을 이곳에 표시
              onSearchSubmitted: (value) {
                print("검색 제출됨: $value");
              },
              onVoiceSearch: () {
                print("음성 검색 실행");
              },
              onSearchChanged: (value) {
                print("검색어 변경됨: $value");
              },
              onTap: () {
                // 이전 페이지로 돌아가면서 검색어를 전달
                Navigator.pop(context, widget.searchQuery);
              },
            ),
          ),

          // 검색 결과 리스트
          Expanded(
            child: ListView.separated(
              itemCount: widget.autoCompleteResults.length,
              itemBuilder: (context, index) {
                final result = widget.autoCompleteResults[index];

                return FutureBuilder<String?>(
                  future: _fetchPlaceDetails(result.placeId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const ListTile(
                        title: Text('정보를 가져오지 못했습니다.'),
                      );
                    } else {
                      final placeName =
                          snapshot.data?.split('\n')[0] ?? '알 수 없는 장소';
                      final address = snapshot.data?.split('\n')[1] ?? '주소 없음';

                      return PlaceCard(
                        lat: _lat ?? 0.0, // Null 값을 0.0으로 대체
                        lng: _lng ?? 0.0, // Null 값을 0.0으로 대체
                        placeName: placeName,
                        address: address,
                        placeId: result.placeId!,
                        checked: _isPlaceBookmarked(result.placeId!),
                        onTap: () {
                          // 장소 선택 시 위도, 경도, 이름을 저장
                          _selectPlace(result.placeId!);
                        },
                      );
                    }
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Color.fromARGB(255, 199, 199, 199),
                  thickness: 0.8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
