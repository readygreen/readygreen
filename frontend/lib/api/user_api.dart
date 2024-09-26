// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트

class NewUserApi {
  final storage = const FlutterSecureStorage();

  Future<String?> login({
    required String email,
    required String password,
    required String nickname,
    required String socialType,
    required String profileImg,
  }) async {
    final String apiUrl = "$baseUrl/auth/login";

    Map<String, String> requestBody = {
      'email': email,
      'nickname': nickname,
      'socialId': password,
      'socialType': socialType.toUpperCase(), // 대문자로 변환
      'profileImg': profileImg,
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
          print('로그인 토큰 저장 accessToken');
          print(accessToken);

          return accessToken; // 로그인 성공 시 accessToken 반환
        } else {
          print('Access Token을 찾을 수 없습니다.');
          return null;
        }
      } else if (response.statusCode == 401) {
        // 401 에러 발생 시 회원가입 요청
        print('로그인 실패: 401 Unauthorized, 회원가입 시도 중...');
        bool signUpSuccess = await signUp(
          email: email,
          nickname: nickname,
          password: password,
          socialType: socialType.toUpperCase(),
          profileImg: profileImg,
        );

        if (signUpSuccess) {
          print('회원가입 성공, 다시 로그인 시도...');
          return await login(
            email: email,
            password: password,
            nickname: nickname,
            socialType: socialType.toUpperCase(),
            profileImg: profileImg,
          );
        } else {
          print('회원가입 실패');
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

  Future<bool> signUp({
    required String email,
    required String nickname,
    required String password,
    required String socialType,
    required String profileImg,
  }) async {
    final String apiUrl = "$baseUrl/auth";

    Map<String, String> requestBody = {
      'email': email,
      'nickname': nickname,
      'socialId': password,
      'socialType': socialType.toUpperCase(), // 대문자로 변환
      'profileImg': profileImg,
    };

    print('회원가입 요청 데이터: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('회원가입 성공');
        return true;
      } else {
        print('회원가입 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      return false;
    }
  }

  // 프로필 불러오기 함수 (이전 코드 유지)
  Future<Map<String, dynamic>?> fetchProfileData() async {
    String? accessToken = await storage.read(key: 'accessToken');
    print('accessToken');
    print(accessToken);

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
          print(response.body);
          return jsonDecode(utf8.decode(response.bodyBytes));
        } else {
          print('프로필 데이터 로드 실패 ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('프로필 데이터 에러 발생 $e');
        return null;
      }
    } else {
      print('토큰 없음');
      return null;
    }
  }
}
