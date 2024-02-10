import 'package:flutter/widgets.dart';

import '../../../models/view-models/user-view-model.dart';

mixin PasswordBehavior<T extends StatefulWidget> on State<T> {
  UserViewModel userViewModel = UserViewModel();
  bool hidePassword = true;

  void onPasswordChanged(String character) {
    setState(() {
      this.userViewModel.password = character.trim();
    });
  }

  void onTogglePasswordVisibility() {
    setState(() {
      this.hidePassword = !this.hidePassword;
    });
  }
}