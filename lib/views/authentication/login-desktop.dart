import 'package:flutter/material.dart';
import 'package:home_management_app/views/authentication/user-controls-mixins/authentication-behavior.dart';
import 'package:home_management_app/views/authentication/registration.dart';

import '../../custom/components/email-textfield.dart';
import '../../custom/components/password-textfield.dart';
import '../mixins/notifier_mixin.dart';
import 'user-controls-mixins/email-behavior.dart';
import 'user-controls-mixins/password-behavior.dart';

class DesktopLoginView extends StatefulWidget {
  const DesktopLoginView({super.key});

  @override
  State<DesktopLoginView> createState() => _DesktopLoginViewState();
}

class _DesktopLoginViewState extends State<DesktopLoginView>
    with AuthenticationBehavior, EmailBehavior, PasswordBehavior, NotifierMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Management'),
      ),
      body: SafeArea(
        child: Column(children: [
          SizedBox(height: 100),
          Container(
            width: 500,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Sign In',
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
                SizedBox(height: 20),
                isAuthenticating
                    ? Padding(
                        padding: EdgeInsets.all(5),
                        child: CircularProgressIndicator())
                    : userViewModel.isPasswordValid
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                            ),
                            child: Icon(Icons.send, color: Colors.white),
                            onPressed:
                                userViewModel.isValid ? onButtonPressed : null,
                          )
                        : OutlinedButton(
                            onPressed: null,
                            child: Icon(Icons.send, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              ),
                        ),
                SizedBox(height: 20),
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
                          Navigator.pushNamed(context, RegistrationScreen.id);
                        },
                        child: Text('Create one'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          )
        ]),
      ),
    );
  }
}
