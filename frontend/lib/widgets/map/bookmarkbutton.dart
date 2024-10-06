import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/api/map_api.dart'; // API 클래스 임포트

class BookmarkButton extends StatefulWidget {
  final String destinationName; // 목적지 이름
  final double latitude; // 목적지 위도
  final double longitude; // 목적지 경도
  final String text;
  final Color borderColor; // 테두리 색상
  final Color textColor; // 텍스트 색상
  final IconData iconData;
  final dynamic placeId;
  final bool checked;

  const BookmarkButton({
    super.key,
    this.text = "즐겨찾기", // 텍스트 기본 값
    this.borderColor = AppColors.green, // 테두리 기본 색상 (초록색)
    this.textColor = AppColors.green, // 텍스트 기본 색상 (초록색)
    this.iconData = Icons.star_rate_rounded,
    required this.destinationName, // 장소 이름을 받아옴
    required this.latitude, // 위도
    required this.longitude, // 경도
    required this.placeId,
    required this.checked,
  });

  @override
  _BookmarkButtonState createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  double? _lat = 0.0;
  double? _lng = 0.0;
  bool _isBookmarked = false;
  final MapStartAPI _api = MapStartAPI(); // API 클래스 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.checked; // checked 값으로 초기화
    _selectPlace(widget.placeId);
  }

  Future<void> _selectPlace(String placeId) async {
    GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');
    final response = await places.getDetailsByPlaceId(placeId, language: 'ko');

    if (response.isOkay) {
      final result = response.result;
      if (mounted) {
        setState(() {
          _lat = result.geometry?.location.lat; // null check 추가
          _lng = result.geometry?.location.lng; // null check 추가
        });
      }
    } else {
      print('장소 선택 실패: ${response.errorMessage}');
    }
  }

  // 북마크 추가 함수 (POST)
  Future<void> _addBookmark() async {
    // 전달된 값들을 로그에 출력
    print('북마크 추가 요청:');
    print('목적지 이름: ${widget.destinationName}');
    print('위도: $_lat');
    print('경도: $_lng');

    bool result = await _api.addBookmark(
      name: "기타", // name은 기타로 고정
      destinationName: widget.destinationName,
      latitude: _lat ?? 0.0,
      longitude: _lng ?? 0.0,
      hour: 0, // 예시로 시간은 0으로 고정
      minute: 0,
      second: 0,
      nano: 0,
      placeId: widget.placeId,
    );
    if (result) {
      print('북마크 추가 성공');
    } else {
      print('북마크 추가 실패');
    }
  }

  // 북마크 삭제 함수 (DELETE)
  Future<void> _deleteBookmark() async {
    print('북마크 삭제 요청: 기타');

    bool result = await _api.deleteBookmark(widget.placeId); // name은 기타로 고정
    if (result) {
      print('북마크 삭제 성공');
    } else {
      print('북마크 삭제 실패');
    }
  }

  // 즐겨찾기 상태를 토글하고 API 호출
  void _toggleBookmark() async {
    if (_isBookmarked) {
      await _deleteBookmark(); // 북마크 삭제 요청
    } else {
      await _addBookmark(); // 북마크 추가 요청
    }
    setState(() {
      _isBookmarked = !_isBookmarked; // 즐겨찾기 상태 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleBookmark, // 클릭 시 즐겨찾기 상태 토글
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: widget.borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 11,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.iconData, // 아이콘
                color: _isBookmarked
                    ? AppColors.yellow
                    : AppColors.grey, // 상태에 따른 아이콘 색상
                size: 22, // 아이콘 크기
              ),
              const SizedBox(width: 3), // 아이콘과 텍스트 간격
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
