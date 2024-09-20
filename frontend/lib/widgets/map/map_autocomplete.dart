import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class AutoCompleteList extends StatelessWidget {
  final List<Prediction> autoCompleteResults;
  final Function(String) onSearchSubmitted;

  const AutoCompleteList({
    super.key,
    required this.autoCompleteResults,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 25,
      right: 25,
      child: Material(
        color: Colors.white,
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: autoCompleteResults.length,
          itemBuilder: (context, index) {
            final prediction = autoCompleteResults[index];
            return ListTile(
              title: Text(prediction.description ?? ""),
              onTap: () {
                onSearchSubmitted(prediction.description!);
              },
            );
          },
        ),
      ),
    );
  }
}
