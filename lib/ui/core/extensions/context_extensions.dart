import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  bool isDarkMode() {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
