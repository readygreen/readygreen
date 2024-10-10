import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/screens/map/mapdirection.dart';

class ArriveButton extends StatefulWidget {
  final String text;
  final Color borderColor; // 테두리 색상
  final Color textColor; // 텍스트 색상
  final IconData iconData; // 이모티콘 (아이콘)
  final double lat; // 전달할 위도
  final double lng; // 전달할 경도
  final String placeName; // 전달할 장소 이름
  final String placeId;

  const ArriveButton({
    super.key,
    this.text = "도착지",
    this.borderColor = AppColors.green,
    this.textColor = AppColors.green,
    this.iconData = Icons.navigation,
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.placeId,
  });

  @override
  _ArriveButtonState createState() => _ArriveButtonState();
}

class _ArriveButtonState extends State<ArriveButton> {
  double? _lat = 0.0;
  double? _lng = 0.0;
  bool _isLoading = true; // 비동기 작업 상태

  Future<void> _selectPlace(String placeId) async {
    GoogleMapsPlaces places =
        GoogleMapsPlaces(apiKey: 'AIzaSyDVYVqfY084OtbRip4DjOh6s3HUrFyTp1M');

    try {
      final response =
          await places.getDetailsByPlaceId(placeId, language: 'ko');

      if (response.isOkay) {
        // null 체크 추가
        final result = response.result;
        if (mounted) {
          setState(() {
            _lat = result.geometry?.location.lat ?? 0.0; // Null 처리
            _lng = result.geometry?.location.lng ?? 0.0; // Null 처리
            _isLoading = false; // 로딩 완료 상태로 변경
          });
        }
      } else {
        print('장소 선택 실패: ${response.errorMessage}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching place details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectPlace(widget.placeId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading
          ? null // 로딩 중에는 버튼을 비활성화
          : () {
              print(
                  '도착지 버튼이 눌렸습니다: ${widget.placeName} (위도: $_lat, 경도: $_lng)');
              // 위도, 경도, 장소 이름을 MapDirectionPage로 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapDirectionPage(
                    endLat: _lat,
                    endLng: _lng,
                    endPlaceName: widget.placeName,
                  ),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: widget.borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 15,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.iconData,
                color: widget.textColor,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                widget.text,
                style: TextStyle(fontSize: 16, color: widget.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
