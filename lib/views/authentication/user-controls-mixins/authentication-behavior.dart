import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../custom/keyboard.factory.dart';
import '../../../models/view-models/user-view-model.dart';
import '../../../services/security/authentication.service.dart';
import '../../main/home.dart';
import '../2fa_view.dart';

mixin AuthenticationBehavior<T extends StatefulWidget> on State<T> {
  UserViewModel userViewModel = UserViewModel();
  bool isAuthenticating = false;

  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();

  KeyboardFactory? keyboardFactory;

  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    loadUser();
  }

  void dispose() {
    super.dispose();
  }

  Future loadUser() async {
    if (await authenticationService.init()) {
      await successFullAuthentication();
    }
  }

  void setAuthenticatingStatus(bool status) {
    setState(() {
      this.isAuthenticating = status;
    });
  }

  Future<void> onButtonPressed() async {
    if (!this.userViewModel.isValid) {
      return;
    }

    setAuthenticatingStatus(true);

    var authenticatedSuccessfully =
        await this.authenticationService.authenticate(this.userViewModel);

    setAuthenticatingStatus(false);

    if (!authenticatedSuccessfully &&
        this.authenticationService.user?.twoFactorRequired == true) {
      this.context.go(TwoFactorAuthenticationView.fullPath);
      return;
    }

    if (authenticatedSuccessfully) {
      await successFullAuthentication();
    } else {
      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication error.'),
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
  }

  Future successFullAuthentication() async {
    this.context.go(HomeScreen.fullPath);
  }

  Future autoAuthenticate() async {
    setAuthenticatingStatus(true);

    var authenticatedSuccessfully =
        await this.authenticationService.biometricsAuthenticate();

    setAuthenticatingStatus(false);

    if (!authenticatedSuccessfully &&
        this.authenticationService.user?.twoFactorRequired == true) {
      this.context.go(TwoFactorAuthenticationView.fullPath);
      return;
    }

    if (authenticatedSuccessfully) {
      await successFullAuthentication();
    } else {
      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication error.'),
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
  }
}
