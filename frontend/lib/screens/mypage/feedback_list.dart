import 'package:flutter/material.dart';
import 'package:readygreen/api/feedback_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/widgets/mypage/bgcontainer_mypage.dart';

class FeedbackListPage extends StatefulWidget {
  @override
  _FeedbackListPageState createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  final FeedbackApi feedbackApi = FeedbackApi();
  List<Map<String, dynamic>> feedbacks = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    List<dynamic>? fetchedNotices = await feedbackApi.getFeedbacks();
    if (fetchedNotices != null) {
      setState(() {
        feedbacks = List<Map<String, dynamic>>.from(fetchedNotices);
        print(feedbacks);
      });
    } else {
      print('피드백 데이터를 가져오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greybg,
      body: SingleChildScrollView(
        child: BgcontainerMypage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                        style: TextStyle(
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                          // color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              feedbacks.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbacks[index];
                        final bool answered = feedback['answered'] ?? false;
                        bool isExpanded = expandedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedIndex =
                                  expandedIndex == index ? null : index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: answered
                                      ? AppColors.routegreen
                                      : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.grey.withOpacity(0.2),
                                //     spreadRadius: 2,
                                //     blurRadius: 6,
                                //     offset: Offset(0, 4),
                                //   ),
                                // ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          feedback['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: answered
                                                ? AppColors.routegreen
                                                : Colors.black87,
                                          ),
                                          maxLines: isExpanded ? null : 1,
                                          overflow: isExpanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        answered
                                            ? Icons.check_circle_outline
                                            : Icons.pending,
                                        color: answered
                                            ? AppColors.routegreen
                                            : Colors.orangeAccent,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    feedback['createDate'].substring(0, 10),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (isExpanded) ...[
                                    SizedBox(height: 12),
                                    Text(
                                      feedback['content'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    if (answered) ...[
                                      Text(
                                        '답변:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.routegreen,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        feedback['reply'] ?? '답변이 없습니다.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              '내 건의사항이 없습니다',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.greytext),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
