import 'package:flutter/material.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';
import 'package:readygreen/widgets/mypage/cardbox_notice.dart';

class FeedbackListPage extends StatelessWidget {
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
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        '내 건의함',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              CardboxNotice()
            ],
          ),
        ),
      ),
    );
  }
}
