import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/mapsearchbar.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/widgets/map/map_autocomplete.dart';

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
      radius: 5000,
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

  // SearchBar의 검색 결과 제출 함수
  void _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    final response = await places.searchByText(query);

    if (response.isOkay) {
      final result = response.results.first;
      final lat = result.geometry!.location.lat;
      final lng = result.geometry!.location.lng;

      // 장소 선택 시 콜백 호출
      widget.onPlaceSelected(lat, lng, result.name);
      Navigator.pop(context); // 검색 후 지도 페이지로 돌아가기
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
              onSearchSubmitted: _onSearchSubmitted,
              onVoiceSearch: () {
                print("음성 검색 시작");
              },
              onSearchChanged: _getAutoCompleteResults,
              onTap: () {},
            ),
          ),
          // 자동완성 결과가 있을 때만 표시
          if (_autoCompleteResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1, // 검색창 아래에 위치
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: AutoCompleteList(
                autoCompleteResults: _autoCompleteResults,
                onSearchSubmitted: _onSearchSubmitted,
              ),
            ),
        ],
      ),
    );
  }
}
