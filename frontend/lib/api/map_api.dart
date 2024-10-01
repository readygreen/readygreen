import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:readygreen/constants/baseurl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MapStartAPI {
  final storage = const FlutterSecureStorage();

  // 경로 요청 (POST)
  Future<Map<String, dynamic>?> fetchRoute({
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required String startName,
    required String endName,
    required bool watch,
  }) async {
    String? accessToken = await storage.read(key: 'accessToken');

    Map<String, dynamic> requestBody = {
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'startName': startName,
      'endName': endName,
      'watch': watch,
    };
    print('길찾기 요청 데이터: $requestBody');
    print('액세스토큰 $accessToken');
    print('Base URL: $baseUrl');

    final response = await http.post(
      Uri.parse('$baseUrl/map/start'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(requestBody),
    );

    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error response body: ${response.body}');
      print('실패 코드: ${response.statusCode}');
      return null;
    }
  }

  // 길안내 정보 요청 (GET)
  Future<Map<String, dynamic>?> fetchGuide() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken == null) {
      print('엑세스 토큰이 없습니다.');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/map/guide'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('길안내 정보 조회 성공');
      return jsonDecode(response.body);
    } else {
      print('길안내 정보 조회 실패: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  // 즐겨찾기 목록 조회 (GET)
  Future<List<dynamic>?> fetchBookmarks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/map/bookmark'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('즐겨찾기 목록 조회 성공');
      return jsonDecode(response.body);
    } else {
      print('즐겨찾기 목록 조회 실패: ${response.statusCode}');
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
    String? accessToken = await storage.read(key: 'accessToken');
    // 시간을 'HH:mm:ss' 형식으로 변환
    String formattedTime = '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse('$baseUrl/map/bookmark'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': name,
        'destinationName': destinationName,
        'latitude': latitude,
        'longitude': longitude,
        'alertTime': formattedTime,
      }),
    );

    if (response.statusCode == 200) {
      print('즐겨찾기 추가 성공: ${response.body}');
      return true;
    } else {
      print('즐겨찾기 추가 실패: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  // 즐겨찾기 삭제 (DELETE)
  Future<bool> deleteBookmark(String name) async {
    String? accessToken = await storage.read(key: 'accessToken');
    final response = await http.delete(
      Uri.parse('$baseUrl/map/bookmark'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      print('즐겨찾기 삭제 성공');
      return true;
    } else {
      print('즐겨찾기 삭제 실패: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

// 신호등 정보 요청 (GET)
  Future<List<dynamic>?> fetchBlinkerInfo({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      print('엑세스 토큰 없어용 ㅜㅜ');
      return null;
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/map?latitude=$latitude&longitude=$longitude&radius=$radius'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('신호등 정보 조회 성공');
      return jsonDecode(response.body)['blinkerDTOs'];
    } else {
      print('신호등 정보 조회 실패: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }
  // 길안내 정보 요청 (GET)
  Future<Map<String, dynamic>?> fetchGuideInfo() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken == null) {
      print('엑세스 토큰이 없습니다.');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/map/guide'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('길안내 정보 조회 성공');
      return jsonDecode(response.body);
    } else {
      print('길안내 정보 조회 실패: ${response.statusCode}');
      return null;
    }
  }

}
