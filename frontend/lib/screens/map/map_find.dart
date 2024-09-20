import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapFind {
  // 경로 찾기 함수
  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    const String apiKey = 'AIzaSyDwyviOI57Suh4mCp_ncISKBbloI5eIayo';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(points);
      }
    }
    return [];
  }

  // Polyline 디코딩 함수
  List<LatLng> _decodePolyline(String poly) {
    var list = poly.codeUnits;
    var lList = <LatLng>[];
    int index = 0;
    int len = poly.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = list[index++] - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = list[index++] - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      lList.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return lList;
  }
}
