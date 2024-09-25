import 'package:flutter/material.dart';
import 'package:readygreen/widgets/map/arrivebutton.dart';
import 'package:readygreen/widgets/map/bookmarkbutton.dart';

class PlaceCard extends StatelessWidget {
  final String placeName;
  final String address;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.placeName,
    required this.address,
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
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 5),
        child: Row(
          children: [
            ArriveButton(),
            SizedBox(width: 8),
            BookmarkButton(),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
