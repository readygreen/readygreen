import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readygreen/api/map_api.dart';
import 'package:readygreen/widgets/map/mapsearchbackbar.dart';
import 'package:readygreen/widgets/map/placecard.dart';
import 'package:readygreen/screens/map/mapsearch.dart';

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

class ResultMapPage extends StatefulWidget {
  final double lat;
  final double lng;
  final String placeName;
  final String address;
  final String searchQuery;
  final dynamic placeId;

  const ResultMapPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.address,
    required this.searchQuery,
    required this.placeId,
  });

  @override
  _ResultMapPageState createState() => _ResultMapPageState();
}

class _ResultMapPageState extends State<ResultMapPage> {
  final MapStartAPI mapStartAPI = MapStartAPI();
  late GoogleMapController mapController;
  late LatLng _center;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  List<BookmarkDTO> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.lat, widget.lng); // 초기 중심 좌표를 전달받은 값으로 설정
    _addMarker(widget.lat, widget.lng, widget.placeName); // 장소 마커 추가
  }

  // 장소 마커를 추가하는 함수
  void _addMarker(double lat, double lng, String placeName) async {
    setState(() {
      _markers.clear(); // 기존 마커 제거
      _markers.add(
        Marker(
          markerId: MarkerId(placeName),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: placeName),
        ),
      );
    });
  }

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

      // 변환한 데이터를 상태에 저장
      setState(() {
        _bookmarks = fetchedBookmarks;
      });
    } else {
      print('북마크 데이터를 불러오지 못했습니다.');
    }
  }

  Future<void> _goToPlace(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _goToPlace(widget.lat, widget.lng); // 전달받은 위치로 카메라 이동
  }

  bool _isPlaceBookmarked(String placeId) {
    return _bookmarks.any((bookmark) => bookmark.placeId == placeId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (widget.placeId == null) {
      return const Center(
          child: Text('잘못된 장소 정보')); // 추가: 위도, 경도, placeId가 없을 때
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          // 검색 바 배치
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.06,
            right: screenWidth * 0.06,
            child: MapSearchBackBar(
              placeName: widget.searchQuery.isNotEmpty
                  ? widget.searchQuery
                  : widget.placeName,
              onSearchSubmitted: (value) {},
              onVoiceSearch: () {},
              onSearchChanged: (value) {},
              onTap: () async {
                // 검색 바 클릭 시 MapSearchPage로 이동
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSearchPage(
                      initialSearchQuery: widget.searchQuery,
                      onPlaceSelected: (lat, lng, placeName) {
                        // 장소가 선택되면 해당 장소로 이동하고 마커 표시
                        _goToPlace(lat, lng);
                        _addMarker(lat, lng, placeName);
                      },
                    ),
                  ),
                );

                // 검색 완료 후 페이지로 돌아오면 결과 처리
                if (result != null) {
                  _goToPlace(result['lat'], result['lng']);
                  _addMarker(result['lat'], result['lng'], result['name']);
                }
              },
            ),
          ),
          // 하단에 PlaceCard 추가
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: PlaceCard(
                lat: widget.lat,
                lng: widget.lng,
                placeName: widget.placeName,
                address: widget.address,
                placeId: widget.placeId,
                checked: _isPlaceBookmarked(widget.placeId),
                onTap: () {
                  // PlaceCard 클릭 시 처리
                  print(
                      'PlaceCard clicked: ${widget.placeName} 위도 ${widget.lat} 경도 ${widget.lng}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
