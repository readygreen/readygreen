import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:readygreen/constants/baseurl.dart'; // baseUrl 임포트
import 'dart:convert';

class PointstepApi {
  final storage = const FlutterSecureStorage();
  final formatter = NumberFormat('#,###');

  Future<String> fetchPoint() async {
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/point'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          // print(jsonDecode(utf8.decode(response.bodyBytes)));
          return  formatter.format(jsonDecode(utf8.decode(response.bodyBytes)));
        } else {
          print('포인트 요청 실패: ${response.statusCode}');
          return '0';
        }
      } catch (e) {
        print('포인트 요청 중 오류 발생: $e');
        return '0';
      }
    } else {
      print('토큰 없음');
      return '0';
    }
  }

  Future<List<Map<String, dynamic>>> fetchSteps() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/point/steps'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          // 받은 데이터를 디코드
          List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

          // 오늘부터 일주일 전까지의 날짜 리스트 생성
          List<Map<String, dynamic>> stepsList = [];
          DateTime today = DateTime.now();

          for (int i = 0; i < 7; i++) {
            DateTime date = today.subtract(Duration(days: i));
            String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

            // 데이터에서 해당 날짜의 걸음수를 찾음
            var stepData = data.firstWhere(
              (entry) => entry['date'] == formattedDate,
              orElse: () => {'id': null, 'date': formattedDate, 'steps': 0}, // 걸음수가 없는 경우
            );

            // 요일 이니셜 계산
            String dayInitial = _getDayInitial(date.weekday);

            stepsList.add({
              'id': stepData['id'],
              'date': stepData['date'],
              'steps': stepData['steps'] ?? 0, // null인 경우 0으로 설정
              'dayInitial': dayInitial, // 요일 이니셜 추가
            });
          }

          return stepsList;
        } else {
          print('걸음수 요청 실패: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        print('걸음수 요청 중 오류 발생: $e');
        return [];
      }
    } else {
      print('토큰 없음');
      return [];
    }
  }

  // 요일 이니셜을 반환하는 메서드
  String _getDayInitial(int weekday) {
    switch (weekday) {
      case 1:
        return 'M'; // 월요일
      case 2:
        return 'T'; // 화요일
      case 3:
        return 'W'; // 수요일
      case 4:
        return 'T'; // 목요일
      case 5:
        return 'F'; // 금요일
      case 6:
        return 'S'; // 토요일
      case 7:
        return 'S'; // 일요일
      default:
        return '';
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchPointList() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/point/list'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'accept': '*/*',
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          Map<String, List<Map<String, dynamic>>> pointsList = {};
          data.forEach((date, points) {
            pointsList[date] = List<Map<String, dynamic>>.from(points.map((point) => {
              'id': point['id'],
              'description': point['description'],
              'point': point['point'],
              'createDate': point['createDate'],
            }));
          });

          return pointsList; // 날짜별 포인트 리스트를 반환
        } else {
          print('포인트 리스트 요청 실패: ${response.statusCode}');
          return {};
        }
      } catch (e) {
        print('포인트 리스트 요청 중 오류 발생: $e');
        return {};
      }
    } else {
      print('토큰 없음');
      return {};
    }
  }



}