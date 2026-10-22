import 'package:home_management_app/data/services/identity.service.dart';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import '2fa_view.dart';

import 'package:home_management_app/ui/core/custom/components/email-textfield.dart';
import 'package:home_management_app/ui/core/custom/components/password-textfield.dart';
import 'package:home_management_app/ui/core/converters/device_language_resolver.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';
import 'user-controls-mixins/authentication-behavior.dart';
import 'user-controls-mixins/email-behavior.dart';
import 'user-controls-mixins/password-behavior.dart';
import 'user-controls-mixins/password-strength-behavior.dart';
import 'user-controls-mixins/post-sign-in.dart';

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
  /// Set when the registration was recorded without telling anyone, so that the
  /// router doesn't move this screen away while the sign-in is running.
  bool _announcePending = false;

  @override
  Future<void> onButtonPressed() async {
    if (!this.userViewModel.isValid) {
      return;
    }

    try {
      await _register();
    } finally {
      // Whatever happened, the flow is over: now the router may act on it.
      if (_announcePending) {
        _announcePending = false;
        GetIt.I<AppModeService>().announceImportStatus();
      }
    }
  }

  Future<void> _register() async {
    setAuthenticatingStatus(true);

    var locale = resolveDeviceLanguage(PlatformDispatcher.instance.locale);

    var registrationResult = await this.authenticationService.register(
        this.userViewModel.email, this.userViewModel.password, locale);

    if (registrationResult == RegistrationResult.success) {
      // Before signing in: if that fails, asks for a 2FA code, or the app closes,
      // the account exists and the move must remember it (SP-01).
      await _rememberRegistration();
      var authenticatedSuccessfully =
          await this.authenticationService.authenticate(this.userViewModel);

      setAuthenticatingStatus(false);

      if (authenticatedSuccessfully) {
        await _afterRegistration();
      } else {
        if (this.authenticationService.user?.twoFactorRequired == true) {
          this.context.go(TwoFactorAuthenticationView.fullPath);
        } else {
          _showErrorDialog('Authentication error.', 'Could not authenticate user.');
        }
      }
    } else if (registrationResult == RegistrationResult.emailTaken) {
      // Stays here, and in local mode if that's where the user is (FR-026).
      setAuthenticatingStatus(false);
      _showErrorDialog('Registration error.',
          AppLocalizations.of(this.context)!.emailAlreadyRegistered);
    } else {
      setAuthenticatingStatus(false);
      _showErrorDialog('Registration error.', 'Could not register user.');
    }
  }

  Future<void> _rememberRegistration() async {
    final appMode = GetIt.I<AppModeService>();
    if (!appMode.isLocal) return;
    try {
      await appMode.markRegistered(userViewModel.email, notify: false);
      _announcePending = true;
    } catch (error, stackTrace) {
      // The account is already created, so carry on with signing in.
      developer.log('Could not record the registration',
          name: 'registration', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _afterRegistration() async {
    if (!mounted) return;
    await goAfterSignIn(this.context);
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
