import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../custom/components/email-textfield.dart';
import '../../custom/components/password-textfield.dart';
import '../main/home.dart';
import 'user-controls-mixins/authentication-behavior.dart';
import 'user-controls-mixins/email-behavior.dart';
import 'user-controls-mixins/password-behavior.dart';
import 'user-controls-mixins/password-strength-behavior.dart';

class RegistrationDesktop extends StatefulWidget {
  const RegistrationDesktop({super.key});

  @override
  State<RegistrationDesktop> createState() => _RegistrationDesktopState();
}

class _RegistrationDesktopState extends State<RegistrationDesktop>
    with
        AuthenticationBehavior,
        EmailBehavior,
        PasswordBehavior,
        PasswordStrengthBehavior {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Management'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100),
            Container(
              width: 500,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Registration',
                      style: TextStyle(fontSize: 34),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: EmailTextField(
                      onTextChanged: onEmailChanged,
                      enableEmailField: !isAuthenticating,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: PasswordTextField(
                        onTextChanged: onPasswordChanged,
                        enablePassword:
                            userViewModel.isEmailValid && !isAuthenticating),
                  ),
                  isAuthenticating
                      ? Padding(
                          padding: EdgeInsets.all(5),
                          child: CircularProgressIndicator())
                      : userViewModel.isPasswordValid
                          ? ElevatedButton(
                              child: Icon(Icons.send, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(200, 50),
                              ),
                              onPressed: userViewModel.isValid
                                  ? onButtonPressed
                                  : null,
                            )
                          : OutlinedButton(
                              onPressed: null,
                              child: Icon(Icons.send, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(200, 50),
                              ),
                            ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Slider(
                        activeColor: getSliderColor(),
                        inactiveColor: getSliderColor(),
                        value: passwordStrength,
                        onChanged: (value) {},
                      )),
                  Padding(
                    padding: EdgeInsets.only(bottom: 1),
                    child: Text('Password strength'),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
            )
          ],
        ),
      ),
    );
  }

  Color getSliderColor() {
    if (passwordStrength >= 0.4 && passwordStrength < 0.6)
      return Colors.red[400]!;

    if (passwordStrength >= 0.6 && passwordStrength < 0.8)
      return Colors.green[200]!;

    if (passwordStrength >= 0.8 && passwordStrength < 1)
      return Colors.green[400]!;

    if (passwordStrength == 1) return Colors.green;

    return Colors.red;
  }
}
