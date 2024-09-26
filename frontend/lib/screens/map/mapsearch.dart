import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/widgets/map/map_autocomplete.dart';
import 'package:readygreen/screens/map/mapsearchresult.dart';

class MapSearchPage extends StatefulWidget {
  final Function(double, double, String) onPlaceSelected;

  const MapSearchPage({super.key, required this.onPlaceSelected});

  @override
  _MapSearchPageState createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
  List<Prediction> _autoCompleteResults = [];

  String _searchQuery = ''; // 검색어를 담는 변수 추가

  // 자동완성 결과를 가져오는 함수
  Future<void> _getAutoCompleteResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _autoCompleteResults.clear(); // 목록 비우기
      });
      return;
    }

    loc.LocationData currentLocation = await loc.Location().getLocation();

    final response = await places.autocomplete(
      query,
      location: Location(
        lat: currentLocation.latitude!,
        lng: currentLocation.longitude!,
      ),
      radius: 7000,
      language: 'ko',
    );

    if (response.isOkay) {
      setState(() {
        _autoCompleteResults = response.predictions;
      });
    } else {
      print('자동완성 실패: ${response.errorMessage}');
    }
  }

  // 장소가 선택되었을 때 지도에 마커를 표시하는 함수
  Future<void> _selectPlace(String placeId) async {
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');
    if (response.isOkay) {
      final result = response.result;
      final lat = result.geometry!.location.lat;
      final lng = result.geometry!.location.lng;

      // 구체적인 지점명이 포함된 장소 이름을 사용
      String placeName = result.name;
      if (result.formattedAddress != null) {
        placeName = result.name;
      }

      // 장소 선택 시 지도에 마커를 표시
      widget.onPlaceSelected(lat, lng, placeName);
      Navigator.pop(context); // 선택 후 지도 페이지로 돌아가기
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
            top: MediaQuery.of(context).size.height * 0.04,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            child: MapSearchBar(
              onSearchSubmitted: _onSearchSubmitted, // 텍스트로 검색 시 결과 페이지로 이동
              onSearchChanged: _getAutoCompleteResults, // 자동완성 결과 갱신
              onTap: () {},
            ),
          ),
          // 자동완성 결과가 있을 때만 표시
          if (_autoCompleteResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: AutoCompleteList(
                autoCompleteResults: _autoCompleteResults,
                onPlaceSelected: _selectPlace, // 장소 선택 시 지도에 표시
              ),
            ),
        ],
      ),
    );
  }
}
