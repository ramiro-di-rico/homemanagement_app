import 'package:flutter/material.dart';
import 'package:home_management_app/custom/main-card.dart';

class TwoFactorAuthenticationWidget extends StatefulWidget {
  TwoFactorAuthenticationWidget({Key? key}) : super(key: key);

  @override
  _TwoFactorAuthenticationWidgetState createState() =>
      _TwoFactorAuthenticationWidgetState();
}

class _TwoFactorAuthenticationWidgetState
    extends State<TwoFactorAuthenticationWidget> {
  bool twoFactorEnabled = false;

  onChecked(bool? value) {
    setState(() {
      this.twoFactorEnabled = value == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
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
