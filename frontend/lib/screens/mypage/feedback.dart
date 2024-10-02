import 'package:flutter/material.dart';
import 'package:readygreen/api/feedback_api.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_feedback.dart';
import 'package:readygreen/widgets/mypage/cardbox_feedback.dart';
import 'package:readygreen/widgets/mypage/cardbox_fbcontent.dart';
import 'package:readygreen/constants/appcolors.dart';


class FeedbackPage extends StatelessWidget {
  final FeedbackApi feedbackApi = FeedbackApi();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    Future<void> submitFeedback() async {
      String title = titleController.text;
      String content = contentController.text;

      try {
        await feedbackApi.submitFeedback(title, content);
        // 애니메이션 효과와 함께 모달 띄우기
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  const SizedBox(height: 10),
                  const Text('제출 성공했습니다!'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 모달 닫기
                    Navigator.pushNamed(context, '/profile'); // 프로필 페이지로 이동
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('제출 실패: $e');
      }
    }

    return Scaffold(
      body: BgcontainerFeedback(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      '건의하기',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            CardboxFeedback(
              height: 50,
              title: '제목',
              child: SizedBox(
                width: deviceWidth * 0.7,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: '제목을 입력해주세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FeedbackContent(
              title: '내용',
              child: SizedBox(
                width: deviceWidth * 0.79,
                child: TextField(
                  controller: contentController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력해주세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greybg, // 초록색 배경
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('제출하기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
