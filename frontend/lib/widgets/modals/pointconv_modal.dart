import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class AgreeModal {
  static void showConversionDialog(BuildContext context, Function onAgree) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text(
                      '포인트전환',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontFamily: 'logoFont',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // 이미지 추가
                    Image.asset(
                      'assets/images/coin2.png', // 이미지 경로
                      height: 90, // 이미지 높이
                    ),
                    // 모달 상단 타이틀
                    const SizedBox(height: 25),

                    const SizedBox(
                      height: 25, // 최대 높이 설정 (스크롤 가능)

                      child: Text(
                        '추후 삼성 페이 포인트로 전환 예정입니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 확인 버튼
                    ElevatedButton(
                      onPressed: () {
                        onAgree();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
