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
    return Card(
      child: SizedBox(
        height: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Checkbox(value: twoFactorEnabled, onChanged: onChecked),
                  Text('Enable Two Factor Authentication')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
