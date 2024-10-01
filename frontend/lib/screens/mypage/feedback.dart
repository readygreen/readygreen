import 'package:flutter/material.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_feedback.dart';
import 'package:readygreen/widgets/mypage/cardbox_fbcontent.dart';
import 'package:readygreen/widgets/mypage/cardbox_feedback.dart';

class FeedbackPage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    // String? selectedCategory;
    // final List<String> categories = ['카테고리 1', '카테고리 2', '카테고리 3'];

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
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                  decoration: InputDecoration(
                    hintText: '제목을 입력해주세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CardboxFeedback(
              height: 50,
              title: '분류',
              child: SizedBox(
                width: deviceWidth * 0.7,
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
