import 'package:flutter/material.dart';

class TwoFactorAuthenticationWidget extends StatefulWidget {
  TwoFactorAuthenticationWidget({Key key}) : super(key: key);

  @override
  _TwoFactorAuthenticationWidgetState createState() => _TwoFactorAuthenticationWidgetState();
}

class _TwoFactorAuthenticationWidgetState extends State<TwoFactorAuthenticationWidget> {

  bool twoFactorEnabled = false;

  onChecked(bool value){
    setState(() {
      this.twoFactorEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeData.dark().bottomAppBarColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: twoFactorEnabled, onChanged: onChecked),
              Text('Enable Two Factor Authentication')
            ],
          ),
        ],
      ),
    );
  }
}