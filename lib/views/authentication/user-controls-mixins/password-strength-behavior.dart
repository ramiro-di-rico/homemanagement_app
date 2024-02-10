import 'package:flutter/widgets.dart';

import '../../../models/view-models/user-view-model.dart';

mixin PasswordStrengthBehavior<T extends StatefulWidget> on State<T> {
  UserViewModel userViewModel = UserViewModel();
  bool enableButton = false;
  double passwordStrength = 0;

  void onPasswordChanged(String character) {
    setState(() {
      userViewModel.password = character;
      measurePasswordStrength();
      this.enableButton = this.passwordStrength > 0.6;
    });
  }

  void measurePasswordStrength() {
    passwordStrength = userViewModel.password.length > 6 ? 0.2 : 0.0;

    passwordStrength =
        passwordStrength + (userViewModel.password.contains(RegExp(r'[0-9]')) ? 0.2 : 0);
    passwordStrength =
        passwordStrength + (userViewModel.password.contains(RegExp(r'[a-z]')) ? 0.2 : 0);
    passwordStrength =
        passwordStrength + (userViewModel.password.contains(RegExp(r'[A-Z]')) ? 0.2 : 0);
    passwordStrength = passwordStrength +
        (userViewModel.password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? 0.2 : 0);
  }
}