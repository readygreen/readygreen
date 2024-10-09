import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class CautionModal extends StatelessWidget {
  final String cautionMessage; // 경고 메시지
  final String cautionImage; // 경고 이미지 경로

  const CautionModal({
    super.key,
    required this.cautionMessage,
    required this.cautionImage,
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
                  '주의!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "LogoFont"),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  cautionImage, // 전달받은 이미지 경로
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  cautionMessage, // 전달받은 경고 메시지
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
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
                  onPressed: () => Navigator.pop(context), // 모달 닫기
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
