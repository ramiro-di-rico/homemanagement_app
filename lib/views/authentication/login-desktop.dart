import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/views/authentication/user-controls-mixins/authentication-behavior.dart';
import 'package:home_management_app/views/authentication/registration.dart';

import '../../custom/components/email-textfield.dart';
import '../../custom/components/password-textfield.dart';
import '../../services/endpoints/identity.service.dart';
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
  
  final IdentityService _identityService = GetIt.I.get<IdentityService>();
  final TextEditingController emailPasswordResetController = TextEditingController();

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
                            child: Icon(Icons.send),
                            onPressed:
                                userViewModel.isValid ? onButtonPressed : null,
                          )
                        : OutlinedButton(
                            onPressed: null,
                            child: Icon(Icons.send),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              ),
                        ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Forgot your password ?'),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Request Password Change'),
                                content: TextField(
                                  controller: emailPasswordResetController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      emailPasswordResetController.clear();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Submit'),
                                    onPressed: () async  {
                                      final email = emailPasswordResetController.text;
                                      await _identityService.requestPasswordChange(email);
                                      emailPasswordResetController.clear();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Email sent to $email'),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Reset it'),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('You don' 't have an account yet ?'),
                      TextButton(
                        onPressed: () {
                          context.go(RegistrationScreen.fullPath);
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
