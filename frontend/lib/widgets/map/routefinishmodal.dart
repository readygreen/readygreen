import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart'; // AppColors 사용을 위해 import

class RouteFinishModal extends StatelessWidget {
  final VoidCallback onConfirm;

  const RouteFinishModal({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '길안내 종료',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "LogoFont"),
                ),
                const SizedBox(height: 20),
                const Text(
                  '목적지에 도착하여 길안내를 종료합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 모달 닫기
                    onConfirm(); // onConfirm 콜백 실행 (페이지 이동)
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
