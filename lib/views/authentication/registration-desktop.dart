import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '2fa_view.dart';

import '../../custom/components/email-textfield.dart';
import '../../custom/components/password-textfield.dart';
import '../mixins/notifier_mixin.dart';
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
        PasswordStrengthBehavior,
        NotifierMixin {
  @override
  Future<void> onButtonPressed() async {
    if (!this.userViewModel.isValid) {
      return;
    }

    setAuthenticatingStatus(true);

    var registrationResult = await this.authenticationService.register(
        this.userViewModel.email, this.userViewModel.password);

    if (registrationResult) {
      var authenticatedSuccessfully =
          await this.authenticationService.authenticate(this.userViewModel);

      setAuthenticatingStatus(false);

      if (authenticatedSuccessfully) {
        await successFullAuthentication();
      } else {
        if (this.authenticationService.user?.twoFactorRequired == true) {
          this.context.go(TwoFactorAuthenticationView.fullPath);
        } else {
          _showErrorDialog('Authentication error.', 'Could not authenticate user.');
        }
      }
    } else {
      setAuthenticatingStatus(false);
      _showErrorDialog('Registration error.', 'Could not register user.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

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
