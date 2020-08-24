import 'package:flutter/material.dart';
import 'package:home_management_app/screens/main/widgets/outcome.widget.dart';

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
              Row(
                children:[
                  Expanded(
                    child: OutcomeWidget()),
                  Expanded(
                    child: OutcomeWidget()),
                ]
              )
            ],
          )),
    );
  }
}