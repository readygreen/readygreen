import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/arrivebutton.dart';
import 'package:readygreen/widgets/map/bookmarkbutton.dart';

class PlaceCard extends StatelessWidget {
  final String placeName;
  final String address;
  final double lat; // 위도
  final double lng; // 경도
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.placeName,
    required this.address,
    required this.lat, // 위도 받기
    required this.lng, // 경도 받기
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 30),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            placeName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            address,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            // 위도, 경도, 장소 이름을 ArriveButton에 넘겨줌
            ArriveButton(
              lat: lat,
              lng: lng,
              placeName: placeName,
            ),
            const SizedBox(width: 8),
            // BookmarkButton에 위도, 경도, 장소 이름 전달
            BookmarkButton(
              destinationName: placeName, // 장소 이름
              latitude: lat, // 위도
              longitude: lng, // 경도
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
