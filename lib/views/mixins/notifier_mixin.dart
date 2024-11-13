import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/infra/error_notifier_service.dart';

mixin NotifierMixin<T extends StatefulWidget> on State<T> {
  NotifierService errorNotifierService = GetIt.instance<NotifierService>();

  void initState() {
    super.initState();
    errorNotifierService.addListener(displayMessage);
  }

  void dispose() {
    errorNotifierService.removeListener(displayMessage);
    super.dispose();
  }

  void displayMessage() {
    var message = errorNotifierService.getMessage();

    if (message == null || message == "null") return;

    if (errorNotifierService.hasError){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
      ));
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.greenAccent,
      ));
    }
  }
}