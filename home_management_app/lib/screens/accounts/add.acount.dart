import 'package:flutter/material.dart';

class AddAccountScreen extends StatefulWidget {
  static const String id = 'add_account_screen';

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            child: Text('Account Page'),
          ),
        ),
      ),
    );
  }
}
