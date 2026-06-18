import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/ui/core/custom/components/email-textfield.dart';
import 'package:home_management_app/ui/core/custom/components/password-textfield.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';
import 'invite_qr_scanner_screen.dart';
import 'registration.dart';
import 'user-controls-mixins/authentication-behavior.dart';
import 'user-controls-mixins/email-behavior.dart';
import 'user-controls-mixins/password-behavior.dart';

class LoginView extends StatefulWidget {
  static const String fullPath = '/login_screen';

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with AuthenticationBehavior,
        EmailBehavior,
        PasswordBehavior,
        NotifierMixin {
  bool _canScanInviteWithCamera(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width <= 720;
    }

    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS;
  }

  Future<void> _openInviteScanner() async {
    final route = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const InviteQrScannerScreen(),
      ),
    );

    if (!mounted || route == null) {
      return;
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signIn),
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
                    enablePassword:
                        userViewModel.isEmailValid && !isAuthenticating),
              ),
              if (isAuthenticating)
                Padding(
                    padding: EdgeInsets.all(5),
                    child: CircularProgressIndicator())
              else
                authenticationService.canAutoAuthenticate()
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton(
                              child: Icon(Icons.send, color: Colors.white),
                              onPressed: userViewModel.isValid
                                  ? onButtonPressed
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton(
                              child: Icon(Icons.fingerprint, color: Colors.white),
                              onPressed: autoAuthenticate,
                            ),
                          ),
                          if (_canScanInviteWithCamera(context))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                onPressed: _openInviteScanner,
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Icon(Icons.send, color: Colors.white),
                            onPressed:
                                userViewModel.isValid ? onButtonPressed : null,
                          ),
                          if (_canScanInviteWithCamera(context))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ElevatedButton(
                                onPressed: _openInviteScanner,
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
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
                          Text(AppLocalizations.of(context)!.dontHaveAccount),
                          TextButton(
                            onPressed: () {
                              context.go(RegistrationScreen.fullPath);
                            },
                            child: Text(AppLocalizations.of(context)!.createOne),
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
