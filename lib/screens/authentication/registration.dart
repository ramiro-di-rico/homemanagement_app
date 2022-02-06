import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/email-textfield.dart';
import 'package:home_management_app/custom/components/password-textfield.dart';
import 'package:home_management_app/screens/main/home.dart';
import 'package:home_management_app/services/authentication.service.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();

  String email = '';
  String password = '';
  bool enablePassword = false;
  bool enableButton = false;
  bool isEmailValid = false;
  bool hidePassword = true;
  bool hideRegistrationLabel = false;
  double passwordStrength = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      floatingActionButton: enableButton
          ? FloatingActionButton(
              onPressed: () async {
                var result =
                    await authenticationService.register(email, password);

                if (result) {
                  await authenticationService.authenticate(email, password);
                  Navigator.pushNamedAndRemoveUntil(
                      context, HomeScreen.id, (route) => false);
                }
              },
              child: Icon(Icons.check),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: EmailTextField(
                  onTextChanged: onEmailChanged,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: PasswordTextField(
                  onTextChanged: onPasswordChanged,
                  enablePassword: enablePassword,
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
      ),
    );
  }

  void onEmailChanged(String character) {
    setState(() {
      this.email = character.trim();
      this.isEmailValid = this.email.contains('@');
      this.enablePassword = this.email.length > 0 && this.isEmailValid;
    });
  }

  void onPasswordChanged(String character) {
    setState(() {
      this.password = character;
      measurePasswordStrength();
      this.enableButton = this.passwordStrength > 0.6;
    });
  }

  void measurePasswordStrength() {
    passwordStrength = password.length > 6 ? 0.2 : 0.0;

    passwordStrength =
        passwordStrength + (password.contains(RegExp(r'[0-9]')) ? 0.2 : 0);
    passwordStrength =
        passwordStrength + (password.contains(RegExp(r'[a-z]')) ? 0.2 : 0);
    passwordStrength =
        passwordStrength + (password.contains(RegExp(r'[A-Z]')) ? 0.2 : 0);
    passwordStrength = passwordStrength +
        (password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? 0.2 : 0);
  }

  Color getSliderColor() {
    if (passwordStrength >= 0.4 && passwordStrength < 0.6)
      return Colors.red[400];

    if (passwordStrength >= 0.6 && passwordStrength < 0.8)
      return Colors.green[200];

    if (passwordStrength >= 0.8 && passwordStrength < 1)
      return Colors.green[400];

    if (passwordStrength == 1) return Colors.green;

    return Colors.red;
  }
}
