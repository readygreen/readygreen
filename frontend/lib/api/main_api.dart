import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트
import 'dart:convert'; // JSON 파싱을 위해 필요

class NewMainApi {
  final storage = FlutterSecureStorage(); // FlutterSecureStorage 객체 생성

  // 오늘의 운세 API 요청
  Future<String?> getFortune() async {
    // 저장된 JWT accessToken 가져오기
    String? accessToken = await storage.read(key: 'accessToken');
    print('운세 accessToken');
    print(accessToken);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/main/fortune'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 400) {
        return response.body;
      } else {
        print('운세 로드 실패 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('운세 에러 발생: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMainData() async {
    String? accessToken = await storage.read(key: 'accessToken');
    print('Main data accessToken');
    print(accessToken);

    try {
      // Construct the URI with query parameters
      final uri = Uri.parse('$baseUrl/main');

      // Send the GET request with the authorization header
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        String utf8Body = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = jsonDecode(utf8Body);

        List<Map<String, dynamic>>? bookmarks =
            (data['bookmarkResponseDTO']?['bookmarkDTOs'] as List?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];

        Map<String, dynamic>? routeRecord = data['routeRecordDTO'] ?? {};

        // Log the data for debugging
        print('Bookmark data: $bookmarks');
        print('Route record data: $routeRecord');

        return {
          'bookmarkDTOs': bookmarks,
          'routeRecordDTO': routeRecord,
          'weatherResponseDTO': data['weatherResponseDTO'],
        }; // Return the relevant data
      } else {
        print('Failed to load main data ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading main data: $e');
      return null;
    }
  }

  // 날씨 API 요청
  Future<List<Map<String, dynamic>>?> getWeather(
      String latitude, String longitude) async {
    // 저장된 JWT accessToken 가져오기
    String? accessToken = await storage.read(key: 'accessToken');
    print('날씨 API accessToken');
    print(accessToken);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/main/weather?x=$latitude&y=$longitude'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // JSON 응답을 List로 파싱
        List<dynamic> decodedResponse = json.decode(response.body);

        // 각 항목이 Map 형식인 List로 변환하여 반환
        return decodedResponse.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print('날씨 정보 로드 실패 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('날씨 API 요청 중 오류 발생: $e');
      return null;
    }
  }
}
