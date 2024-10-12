import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/arrivebutton.dart';
import 'package:readygreen/widgets/map/bookmarkbutton.dart';

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

class PlaceCard extends StatelessWidget {
  final String placeName;
  final String address;
  final double lat; // 위도
  final double lng; // 경도
  final VoidCallback onTap;
  final dynamic placeId;
  final bool checked;

  const PlaceCard(
      {super.key,
      required this.placeName,
      required this.address,
      required this.lat, // 위도 받기
      required this.lng, // 경도 받기
      required this.onTap,
      required this.placeId,
      required this.checked});

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
              placeId: placeId,
            ),
            const SizedBox(width: 8),
            // BookmarkButton에 위도, 경도, 장소 이름 전달
            BookmarkButton(
                destinationName: address, // 장소 이름
                latitude: lat, // 위도
                longitude: lng, // 경도
                placeId: placeId,
                checked: checked),
          ],
        ),
      ),
      onTap: () {
        // PlaceCard 전체가 눌렸을 때 확인
        print('PlaceCard tapped: $placeName, lat: $lat, lng: $lng');
        onTap();
      },
    );
  }
}
