import 'package:flutter/material.dart';
import 'package:readygreen/api/main_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가
import 'package:readygreen/api/user_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BirthModal extends StatefulWidget {
  const BirthModal({Key? key}) : super(key: key);

  @override
  _BirthModalState createState() => _BirthModalState();
}

class _BirthModalState extends State<BirthModal> {
  DateTime _selectedDate = DateTime.now();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final NewUserApi userApi = NewUserApi();
  final NewMainApi mainApi = NewMainApi();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Container(
            width: deviceWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '생일 등록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LogoFont',
                    color: AppColors.pink,
                  ),
                ),
                const SizedBox(height: 20),
                // 달력
                Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.green, // 선택된 날짜의 배경 색상
                      onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
                      onSurface: Colors.black, // 기본 날짜 텍스트 색상
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    onDateChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // 등록 버튼
                ElevatedButton(
                  onPressed: () async {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(_selectedDate);
                    print(formattedDate);

                    try {
                      // updateBirth의 반환값을 DateTime?로 기대
                      DateTime? result =
                          await userApi.updateBirth(formattedDate);

                      // 반환된 값이 null이 아니면 성공적으로 생일이 업데이트됨
                      if (result != null) {
                        Navigator.of(context).pop(true); // 성공 시 true 반환
                      } else {
                        Navigator.of(context).pop(false); // 실패 시 false 반환
                      }
                    } catch (e) {
                      print('생일 업데이트 실패: $e');
                      Navigator.of(context).pop(false); // 오류 발생 시 false 반환
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 선택',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 닫기 버튼
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 30,
                color: AppColors.greytext,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 모달 닫기
              },
            ),
          ),
        ],
      ),
    );
  }
}
