import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트
import 'dart:convert';

class NoticeApi {
  final storage = const FlutterSecureStorage();

  Future<List<dynamic>?> fetchNoticeData() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/notice'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          print('공지사항 데이터 요청 성공');
          // print(jsonDecode(utf8.decode(response.bodyBytes)));
          return jsonDecode(utf8.decode(response.bodyBytes));
        } else {
          print('공지사항 데이터 요청 실패: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('공지사항 데이터 요청 중 오류 발생: $e');
        return null;
      }
    } else {
      print('토큰 없음');
      return null;
    }
  }
}
