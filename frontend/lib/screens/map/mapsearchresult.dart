import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/widgets/map/mapsearchbackbar.dart';
import 'package:readygreen/widgets/map/placecard.dart';

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
  double? _lat;
  double? _lng;
  String? _placeName;

  // 캐싱된 장소 정보를 저장할 Map
  Map<String, Future<String>> cachedPlaceDetails = {};

  // 세부 정보 가져오는 함수
  Future<String> _getDetailedInfo(String placeId) {
    if (!cachedPlaceDetails.containsKey(placeId)) {
      // 해당 placeId가 아직 캐시되지 않았다면 API 호출
      cachedPlaceDetails[placeId] = _fetchPlaceDetails(placeId);
    }
    return cachedPlaceDetails[placeId]!;
  }

  // 실제 Google Places API를 호출하는 함수
  Future<String> _fetchPlaceDetails(String placeId) async {
    GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');

    if (response.isOkay) {
      final result = response.result;
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
        _lat = result.geometry!.location.lat;
        _lng = result.geometry!.location.lng;
        _placeName = result.name;
      });

      // 위도, 경도, 장소 이름 출력 (확인용)
      print('위도: $_lat, 경도: $_lng, 장소 이름: $_placeName');

      // 장소 선택 시 위도, 경도, 이름을 지도 페이지로 전달하고 돌아감
      Navigator.pop(context, {'lat': _lat, 'lng': _lng, 'name': _placeName});
    } else {
      print('장소 선택 실패: ${response.errorMessage}');
    }
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
              top: MediaQuery.of(context).size.height * 0.04,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
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
            ),
          ),

          // 검색 결과 리스트
          Expanded(
            child: ListView.separated(
              itemCount: widget.autoCompleteResults.length,
              itemBuilder: (context, index) {
                final result = widget.autoCompleteResults[index];

                return FutureBuilder<String?>(
                  future: _getDetailedInfo(result.placeId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text('로딩 중...'),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      return const ListTile(
                        title: Text('정보를 가져오지 못했습니다.'),
                      );
                    } else {
                      final placeName =
                          snapshot.data?.split('\n')[0] ?? '알 수 없는 장소';
                      final address = snapshot.data?.split('\n')[1] ?? '주소 없음';

                      return PlaceCard(
                        placeName: placeName,
                        address: address,
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
