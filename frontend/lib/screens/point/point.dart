import 'package:flutter/material.dart';
import 'package:readygreen/widgets/common/bgcontainer.dart';

class PointPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BackgroundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'Point',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              // 다른 위젯 추가 가능
            ],
          ),
        ),
      ),
    );
  }
}
