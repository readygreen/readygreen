import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:readygreen/constants/baseurl.dart';

class MapAPI {
  // 경로 요청을 위한 POST 함수
  Future<Map<String, dynamic>?> fetchRoute({
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required String startName,
    required String endName,
    required bool watch,
  }) async {
    final url = Uri.parse('$baseUrl/map/start');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'startX': startX,
        'startY': startY,
        'endX': endX,
        'endY': endY,
        'startName': startName,
        'endName': endName,
        'watch': watch,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch route: ${response.statusCode}');
      return null;
    }
  }
}
