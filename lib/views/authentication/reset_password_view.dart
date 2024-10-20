import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../services/security/password_reset_service.dart';
import 'login.dart';

class ResetPasswordView extends StatefulWidget {
  static const String fullPath = '/reset_password';

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final PasswordResetService _passwordResetService =
      GetIt.I.get<PasswordResetService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.text = _passwordResetService.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text('Enter your email address to reset your password'),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 30),
                Text('Enter your new password'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 30),
                Text('Repeat your new password'),
                TextField(
                  obscureText: true,
                  controller: repeatPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Repeat Password',
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text.isEmpty ||
                            repeatPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password cannot be empty'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (passwordController.text !=
                            repeatPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Passwords do not match'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        showSuccessSnackBar(context, 'Password reset successful');
                      },
                      child: Text('Reset Password'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _passwordResetService.clearResetPasswordQueryParams();
                        showSuccessSnackBar(context, 'Navigating back to login');
                        context.go(LoginView.fullPath);
                      },
                      child: Text('Back to Login'),
                    ),
                  ],
                ),
              ],
            ),
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
