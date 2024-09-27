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

    if (accessToken != null) {
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
    } else {
      print('accessToken이 없습니다.');
      return null;
    }
  }

  // 날씨 API 요청
  Future<Map<String, dynamic>?> getWeather(
      String latitude, String longitude) async {
    // 저장된 JWT accessToken 가져오기
    String? accessToken = await storage.read(key: 'accessToken');
    print('날씨 API accessToken');
    print(accessToken);

    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/main/weather?x=$latitude&y=$longitude'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // JSON 응답을 파싱
          return json.decode(response.body);
        } else {
          print('날씨 정보 로드 실패 ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('날씨 API 요청 중 오류 발생: $e');
        return null;
      }
    } else {
      print('accessToken이 없습니다.');
      return null;
    }
  }
}
