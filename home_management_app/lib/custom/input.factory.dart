import 'package:flutter/material.dart';

class InputFactory {

  static InputDecoration createdRoundedOutLineDecoration(String label) {
    return InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        labelText: label);
  }
}
