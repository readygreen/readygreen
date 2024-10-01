import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class MapSearchResultPage extends StatelessWidget {
  final List<Prediction> searchResults;

  const MapSearchResultPage({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final prediction = searchResults[index];
          return ListTile(
            title: Text(prediction.description ?? ""),
            onTap: () {
              // 장소 선택 시 동작
              Navigator.pop(context, prediction); // 선택한 장소로 돌아가기
            },
          );
        },
      ),
    );
  }
}
