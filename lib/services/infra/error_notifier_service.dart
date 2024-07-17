import 'package:flutter/cupertino.dart';

class ErrorNotifierService extends ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  void notifyError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String? getError() {
    var message = _errorMessage.toString();
    _errorMessage = null;
    return message;
  }
}