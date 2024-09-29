import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:readygreen/constants/baseurl.dart';

class MapStartAPI {
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

  // 즐겨찾기 목록 조회 (GET)
  Future<List<dynamic>?> fetchBookmarks() async {
    final url = Uri.parse('$baseUrl/map/bookmark');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch bookmarks: ${response.statusCode}');
      return null;
    }
  }

  // 즐겨찾기 추가 (POST)
  Future<bool> addBookmark({
    required String name,
    required String destinationName,
    required double latitude,
    required double longitude,
    required int hour,
    required int minute,
    required int second,
    required int nano,
  }) async {
    final url = Uri.parse('$baseUrl/map/bookmark');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'destinationName': destinationName,
        'latitude': latitude,
        'longitude': longitude,
        'alertTime': {
          'hour': hour,
          'minute': minute,
          'second': second,
          'nano': nano,
        },
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add bookmark: ${response.statusCode}');
      return false;
    }
  }

  // 즐겨찾기 삭제 (DELETE)
  Future<bool> deleteBookmark(String name) async {
    final url = Uri.parse('$baseUrl/map/bookmark');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete bookmark: ${response.statusCode}');
      return false;
    }
  }
}
