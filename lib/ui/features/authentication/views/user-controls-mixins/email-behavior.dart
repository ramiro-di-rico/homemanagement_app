import 'package:flutter/widgets.dart';

import 'package:home_management_app/ui/features/authentication/view_models/user-view-model.dart';

mixin EmailBehavior<T extends StatefulWidget> on State<T>{
  UserViewModel userViewModel = UserViewModel();

  void onEmailChanged(String character) {
    setState(() {
      this.userViewModel.email = character.trim();
    });
  }
}