import 'package:flutter/cupertino.dart';

class NotifierService extends ChangeNotifier {
  String? _message;
  bool? _isError;
  String? get errorMessage => _message;

  bool get hasError => _isError ?? false;

  void notify(String message, {bool isError = false}) {
    _message = message;
    _isError = isError;
    notifyListeners();
  }

  String? getMessage() {
    if (_message == null) return null;
    var message = _message!;
    _message = null;
    return message;
  }
}