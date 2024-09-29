import 'package:flutter/material.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';
import 'package:readygreen/widgets/mypage/cardbox_notice.dart';

class FeedbackDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BgcontainerMypage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ' 공지사항',
                  style: TextStyle(fontSize: 21),
                ),
              ),
              const SizedBox(height: 10),
              CardboxNotice()
            ],
          ),
        ),
      ),
    );
  }
}
