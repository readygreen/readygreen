import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/screens/map/resultmap.dart';
import 'package:readygreen/screens/map/mapsearchresult.dart';

class MapSearchPage extends StatefulWidget {
  final Function(double, double, String) onPlaceSelected;
  final String? initialSearchQuery;

  const MapSearchPage(
      {super.key, required this.onPlaceSelected, this.initialSearchQuery});

  @override
  _MapSearchPageState createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');

  late String _searchQuery = ''; // 검색어를 담는 변수 추가
  @override
  void initState() {
    super.initState();
    // 초기 검색어를 설정, 없으면 빈 문자열
    _searchQuery = widget.initialSearchQuery ?? '';
  }

  // 장소가 선택되었을 때 지도에 마커를 표시하는 함수
  Future<void> _selectPlace(String placeId) async {
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');
    if (response.isOkay) {
      final result = response.result;
      final lat = result.geometry!.location.lat;
      final lng = result.geometry!.location.lng;
      final placeName = result.name;
      final address = result.formattedAddress ?? '';

      // 장소 선택 시 ResultMapPage로 정보 전달
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultMapPage(
            lat: lat,
            lng: lng,
            placeName: placeName,
            address: address,
            searchQuery: _searchQuery,
          ),
        ),
      );
    } else {
      print('장소 선택 실패: ${response.errorMessage}');
    }
  }

  // SearchBar의 검색 결과 제출 함수
  void _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query; // 검색어를 변수에 저장
    });
    print('검색 제출됨: $_searchQuery'); // 검색 제출 로그

    final response = await places.searchByText(query, language: 'ko');

    if (response.isOkay) {
      final predictions = response.results.map((result) {
        return Prediction(
          description: result.name,
          placeId: result.placeId,
        );
      }).toList();

      print('검색 결과: ${predictions.length}'); // 검색 결과 확인
      print('페이지 전환 시작'); // 페이지 전환 로그 추가

      // 검색 결과를 결과 페이지로 전달
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapSearchResultPage(
            autoCompleteResults: predictions,
            searchQuery: _searchQuery,
          ),
        ),
      ).then((_) {
        print('페이지 전환 완료'); // 페이지 전환 후 로그
      });
    } else {
      print('검색 실패: ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 검색 바 추가
          Positioned(
            top: MediaQuery.of(context).size.height * 0.06,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06,
            child: MapSearchBar(
              initialValue: _searchQuery,
              onSearchSubmitted: _onSearchSubmitted, // 텍스트로 검색 시 결과 페이지로 이동
              onSearchChanged: (value) {}, // 자동완성 기능 제거
              onTap: () {}, // 검색창 클릭 시 추가 동작 없음
            ),
          ),
        ],
      ),
    );
  }
}
