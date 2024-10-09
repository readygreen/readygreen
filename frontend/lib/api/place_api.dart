import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트
import 'dart:convert'; // JSON 파싱을 위해 필요

class PlaceApi {
  final storage = const FlutterSecureStorage();

  Future<dynamic> getPlaces({
    required String type,
    required double userLatitude,
    required double userLongitude,
  }) async {
    String? accessToken = await storage.read(key: 'accessToken');
    print('장소 api parameter : $type, $userLatitude, $userLongitude');
    final response = await http.get(
      Uri.parse(
          '$baseUrl/place/nearby?type=$type&userLatitude=$userLatitude&userLongitude=$userLongitude'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('place 장소 추천 성공');
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      print('API 응답 데이터: $decodedResponse');
      return decodedResponse;
    } else {
      print('place 장소 추천 실패');
    }
  }

  // nearby/all (GET)
  Future<List<dynamic>> getAllNearbyPlaces({
    required double userLatitude,
    required double userLongitude,
  }) async {
    String? accessToken = await storage.read(key: 'accessToken');
    print('장소 전체 추천 요청: $userLatitude, $userLongitude');
    final response = await http.get(
      Uri.parse(
          '$baseUrl/place/nearby/all?userLatitude=$userLatitude&userLongitude=$userLongitude'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print('전체 장소 추천 성공');
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      print('API 응답 데이터: $decodedResponse');
      return decodedResponse;
    } else {
      print('전체 장소 추천 실패');
      throw Exception('Failed to load nearby places');
    }
  }
}
