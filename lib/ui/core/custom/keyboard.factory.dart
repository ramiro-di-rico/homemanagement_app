import 'package:flutter/cupertino.dart';

class KeyboardFactory {
  BuildContext context;

  KeyboardFactory({required this.context});

  bool isKeyboardVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  void unFocusKeyboard() {
    FocusScope.of(context).unfocus();
  }
}
