import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_data_unavailable_message.dart';
import 'package:home_management_app/ui/features/authentication/views/user-controls-mixins/authentication-behavior.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';

import 'package:home_management_app/ui/core/custom/components/email-textfield.dart';
import 'package:home_management_app/ui/core/custom/components/password-textfield.dart';
import 'package:home_management_app/data/services/identity.service.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';
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
  final AppModeService _appModeService = GetIt.I.get<AppModeService>();
  bool _enteringLocal = false;

  Future<void> _useWithoutAccount() async {
    if (_enteringLocal) return;
    setState(() => _enteringLocal = true);
    try {
      await _appModeService.enterLocalMode();
      if (!mounted) return;
      context.go(HomeScreen.fullPath);
    } on LocalDataUnavailableException catch (e) {
      if (!mounted) return;
      // Not busy any more, so the button is not left spinning behind the dialog.
      setState(() => _enteringLocal = false);
      final l10n = AppLocalizations.of(context)!;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.localModeUnavailableTitle),
          content: Text(localDataUnavailableMessage(l10n, e.reason)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _enteringLocal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible =
        keyboardInset > 0 || (keyboardFactory?.isKeyboardVisible() ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Management'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: isKeyboardVisible ? 16 : 100),
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
                  if (isAuthenticating)
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator(),
                    )
                  else
                    userViewModel.isPasswordValid
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
                        Expanded(child: Text('Forgot your password ?')),
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
                        Expanded(child: Text('You don' 't have an account yet ?')),
                        TextButton(
                          onPressed: () {
                            context.go(RegistrationScreen.fullPath);
                          },
                          child: Text('Create one'),
                        )
                      ],
                    ),
                  ),
                  if (_appModeService.isLocalAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _enteringLocal
                          ? TextButton.icon(
                              onPressed: null,
                              icon: const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2)),
                              label: Text(AppLocalizations.of(context)!.useWithoutAccount),
                            )
                          : TextButton(
                              onPressed: isAuthenticating ? null : _useWithoutAccount,
                              child: Text(AppLocalizations.of(context)!.useWithoutAccount),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
