import 'package:flutter/material.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';
import 'package:readygreen/widgets/mypage/cardbox_fbcontent.dart';
import 'package:readygreen/widgets/mypage/cardbox_feedback.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BgcontainerMypage(
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
                child: Text('제목을 입력해주세요'),
              ),
              const SizedBox(height: 10),
              CardboxFeedback(
                height: 50,
                title: '분류',
              ),
              const SizedBox(height: 10),
              FeedbackContent(
                title: '내용',
                child: Text('내용을 입력해주세요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
