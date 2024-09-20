import 'package:flutter/material.dart';

class PlacePage extends StatelessWidget {
  const PlacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Page'),
      ),
      body: Center(
        child: Text(
          'This is the Place Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
