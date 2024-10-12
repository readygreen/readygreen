import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class AutoCompleteList extends StatelessWidget {
  final List<Prediction> autoCompleteResults;
  final Function(String) onPlaceSelected; // placeId를 받아 처리하는 함수

  const AutoCompleteList({
    super.key,
    required this.autoCompleteResults,
    required this.onPlaceSelected, // 수정된 부분
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 5.0,
      borderRadius: BorderRadius.circular(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: autoCompleteResults.length,
        itemBuilder: (context, index) {
          final prediction = autoCompleteResults[index];
          return ListTile(
            title: Text(prediction.description ?? ""), // 장소 이름
            subtitle:
                Text(prediction.structuredFormatting?.secondaryText ?? ""),
            onTap: () {
              // 장소 선택 시 placeId를 사용하여 처리
              onPlaceSelected(prediction.placeId!); // placeId 전달
            },
          );
        },
      ),
    );
  }
}
