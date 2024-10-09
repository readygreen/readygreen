import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart';

class TrafficLightApi {
  final storage = const FlutterSecureStorage();

  // 신호등 데이터 요청 함수 (임시 내일 보고 수정)
  Future<Map<String, dynamic>?> fetchTrafficLightData() async {
    String? accessToken = await storage.read(key: 'accessToken');
    print('accessToken');
    print(accessToken);

    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/map/blinker'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          print('신호등 데이터 요청 성공');
          print(response.body);
          return jsonDecode(utf8.decode(response.bodyBytes));
        } else {
          print('신호등 데이터 요청 실패: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('신호등 데이터 요청 중 오류 발생: $e');
        return null;
      }
    } else {
      print('토큰 없음');
      return null;
    }
  }
}
