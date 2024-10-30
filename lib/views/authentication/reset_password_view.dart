import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../services/endpoints/identity.service.dart';
import '../../services/security/password_reset_service.dart';
import 'login.dart';
import 'user-controls-mixins/password-strength-behavior.dart';

class ResetPasswordView extends StatefulWidget {
  static const String fullPath = '/reset_password';

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> with PasswordStrengthBehavior {
  final PasswordResetService _passwordResetService =
      GetIt.I.get<PasswordResetService>();
  final IdentityService _identityService = GetIt.I.get<IdentityService>();

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
        title: Center(child: Text('Reset Password')),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text('Your email address'),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 30),
                Text('Enter your new password'),
                TextField(
                  controller: passwordController,
                  onChanged: onPasswordChanged,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                      onPressed: () async {
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

                        var success = await _identityService.changePassword(_passwordResetService.email, passwordController.text, _passwordResetService.token);

                        if (success) {
                          showSuccessSnackBar(context, 'Password reset successful');
                          context.go(LoginView.fullPath);
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password reset failed'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Text('Reset Password'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _passwordResetService.clearResetPasswordQueryParams();
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
