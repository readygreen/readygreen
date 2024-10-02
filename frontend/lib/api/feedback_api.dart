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
}