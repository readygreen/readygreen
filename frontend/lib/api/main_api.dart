import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트

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
          // JSON 응답 파싱
          final responseBody = response.body;
          print('responseBody'); // 콘솔에 출력
          print(responseBody); // 콘솔에 출력
          return responseBody; // 'fortune' 필드만 반환
        } else if (response.statusCode == 400) {
          final responseBody = response.body;
          print('responseBody'); // 콘솔에 출력
          print(responseBody); // 콘솔에 출력
          return responseBody; // 'fortune' 필드만 반환
        } else {
          print('운세 로드 실패 ${response.statusCode}');
          return null; // 실패 시에도 null 반환
        }
      } catch (e) {
        print('운세 에러 발생: $e');
        return null; // 예외 발생 시 null 반환
      }
    } else {
      print('accessToken이 없습니다.');
      return null; // accessToken이 없을 때도 null 반환
    }
  }
}
