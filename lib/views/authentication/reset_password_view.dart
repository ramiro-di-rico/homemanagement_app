import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'login.dart';

class ResetPasswordView extends StatefulWidget {
  static const String fullPath = '/reset_password';

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Reset Password'),
              Text('Enter your email address to reset your password'),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showSuccessSnackBar(context, 'Password reset email sent');
                },
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
