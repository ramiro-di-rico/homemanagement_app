import 'package:flutter/material.dart';
import 'package:home_management_app/custom/components/email-textfield.dart';
import 'package:home_management_app/custom/components/password-textfield.dart';
import 'registration.dart';
import 'authentication-controls.dart';

class LoginView extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with AuthenticationControls {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(
            children: [
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
                    enablePassword: userViewModel.isEmailValid && !isAuthenticating),
              ),
              isAuthenticating
                  ? Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator())
                  : ElevatedButton(
                      child: Icon(Icons.send, color: Colors.white),
                      onPressed: userViewModel.isValid ? onButtonPressed : null,
                    ),
            ],
          ),
          Column(
            children: keyboardFactory?.isKeyboardVisible() ?? false
                ? []
                : [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Text('You don' 't have an account yet ?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RegistrationScreen.id);
                            },
                            child: Text('Create one'),
                          )
                        ],
                      ),
                    )
                  ],
          )
        ]),
      ),
    );
  }
}
