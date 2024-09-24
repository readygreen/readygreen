// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트

class UserApi {
  final storage = const FlutterSecureStorage();

  // 프로필 불러오기
  Future<Map<String, dynamic>?> fetchProfileData() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          print('Failed to load profile data: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Error fetching profile data: $e');
        return null;
      }
    } else {
      print('No access token found');
      return null;
    }
  }

  // 로그인 요청 함수
  Future<String?> login(String email, String password) async {
    final String apiUrl = "$baseUrl/auth/login";

    Map<String, String> requestBody = {
      'email': email,
      'socialId': password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        String? authorizationHeader = response.headers['authorization'];
        if (authorizationHeader != null &&
            authorizationHeader.startsWith('Bearer ')) {
          String accessToken = authorizationHeader.substring(7);

          // accessToken을 SecureStorage에 저장
          await storage.write(key: 'accessToken', value: accessToken);

          return accessToken; // 로그인 성공 시 accessToken 반환
        } else {
          print('Access Token을 찾을 수 없습니다.');
          return null;
        }
      } else {
        print('로그인 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      return null;
    }
  }
}
