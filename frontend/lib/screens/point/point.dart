import 'package:flutter/material.dart';

class PointPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Point Page'),
      ),
      body: Center(
        child: Text(
          'point',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
