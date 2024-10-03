import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:readygreen/constants/baseurl.dart';

class FeedbackApi {
  final storage = const FlutterSecureStorage();

  Future<String?> submitFeedback(String title, String content) async {
    // 저장된 JWT accessToken 가져오기
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        Map<String, String> requestBody = {
          'title': title,
          'content': content,
        };

        final response = await http.post(
          Uri.parse('$baseUrl/question'),  // 피드백 제출 API URL
          headers: {
            'Authorization': 'Bearer $accessToken',
            'accept': '*/*',
            'Content-Type': 'application/json',  // JSON 형식으로 전송
          },
          body: jsonEncode(requestBody),  // 요청 데이터 JSON 변환
        );

        if (response.statusCode == 200) {
          // 요청 성공 시
          print('피드백 제출 성공');
          return response.body;
        } else {
          // 서버에서 에러 발생 시
          print('피드백 제출 실패 ${response.statusCode}');
          return response.body;
        }
      } catch (e) {
        // 예외 처리
        print('피드백 제출 에러 발생: $e');
        return null;
      }
    } else {
      // accessToken이 없을 경우
      print('accessToken이 없습니다.');
      return null;
    }
  }

  Future<List<dynamic>?> getFeedbacks() async {
  // 저장된 JWT accessToken 가져오기
  String? accessToken = await storage.read(key: 'accessToken');

  if (accessToken != null) {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/question'),  // 피드백 가져오기 API URL
        headers: {
          'Authorization': 'Bearer $accessToken',
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        // 요청 성공 시
        print('피드백 가져오기 성공');

        // 응답을 UTF-8로 변환하여 JSON 데이터로 파싱
        String responseBody = utf8.decode(response.bodyBytes);
        return jsonDecode(responseBody);  // JSON 데이터로 변환하여 반환
      } else {
        // 서버에서 에러 발생 시
        print('피드백 가져오기 실패 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // 예외 처리
      print('피드백 가져오기 에러 발생: $e');
      return null;
    }
  } else {
    // accessToken이 없을 경우
    print('accessToken이 없습니다.');
    return null;
  }
}

}
