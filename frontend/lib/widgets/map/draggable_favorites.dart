import 'package:flutter/material.dart';
import 'package:readygreen/widgets/common/textbutton.dart';

class DraggableFavorites extends StatelessWidget {
  final ScrollController scrollController;

  const DraggableFavorites({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.04,
      minChildSize: 0.04, // 최소 높이
      maxChildSize: 0.85, // 최대 높이
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 인디케이터
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              // 즐겨찾기 목록
              Expanded(
                child: ListView(
                  controller: scrollController, // 리스트가 스크롤 가능하도록 설정
                  children: const [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        '자주 가는 목적지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                        // 임시로 데이터 입력해서 출력함
                        leading: Icon(Icons.business),
                        title: Text('삼성화재 유성 연수원'),
                        subtitle: Text('대전 유성구 동서대로 98-39'),
                        trailing: CustomButton()),
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
