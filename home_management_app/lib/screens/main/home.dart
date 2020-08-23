import 'package:flutter/material.dart';
import 'widgets/test.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home')
      ),
      body: Center(
          child: Column(
            children: [
              Text('Home'),
              TestWidget()
            ],
          )),
    );
  }
}