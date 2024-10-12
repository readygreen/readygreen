import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트

class WatchApi {
  final storage = FlutterSecureStorage();

  Future<String> watchNum({
    required String watchNumber,
  }) async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/link?authNumber=$watchNumber'),
          headers: {
            'Authorization': 'Bearer $accessToken', // Access Token 포함
            'accept': '*/*', // 모든 응답 타입 허용
          },
        );

        if (response.statusCode == 200) {
          return response.body; // 성공 메시지 또는 데이터를 반환
        } else {
          print('워치 코드 전송 실패: ${response.statusCode}');
          print('응답 내용: ${response.body}');
          return 'Failed: ${response.body}'; // 실패 메시지 반환
        }
      } catch (e) {
        print('워치 전송 중 오류 발생: $e');
        return 'Error: $e'; // 오류 메시지 반환
      }
    } else {
      print('Access Token이 없습니다.');
      return 'No Access Token'; // 토큰 없을 때 반환
    }
  }
}
