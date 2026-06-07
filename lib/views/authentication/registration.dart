import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/email-textfield.dart';
import 'package:home_management_app/custom/components/password-textfield.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/views/authentication/user-controls-mixins/password-strength-behavior.dart';
import 'package:home_management_app/views/authentication/2fa_view.dart';
import 'package:home_management_app/views/main/home.dart';
import 'package:home_management_app/services/security/authentication.service.dart';

import '../mixins/notifier_mixin.dart';
import 'user-controls-mixins/email-behavior.dart';
import 'user-controls-mixins/password-behavior.dart';

class RegistrationScreen extends StatefulWidget {
  static const String fullPath = '/registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with PasswordBehavior, EmailBehavior, PasswordStrengthBehavior, NotifierMixin {
  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registration),
      ),
      floatingActionButton: enableButton
          ? FloatingActionButton(
              onPressed: () async {
                var result =
                    await authenticationService.register(userViewModel.email, userViewModel.password);

                if (result) {
                  var authenticatedSuccessfully = await authenticationService.authenticate(userViewModel);
                  if (authenticatedSuccessfully) {
                    context.go(HomeScreen.fullPath);
                  } else {
                    if (authenticationService.user?.twoFactorRequired == true) {
                      context.go(TwoFactorAuthenticationView.fullPath);
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.authenticationError),
                              content: Text(AppLocalizations.of(context)!.couldNotAuthenticateAfterRegistration),
                              actions: [
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  }
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Registration error.'),
                          content: Text('Could not register user.'),
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
                  enableEmailField: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: PasswordTextField(
                  onTextChanged: onPasswordChanged,
                  enablePassword: userViewModel.isEmailValid,
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
