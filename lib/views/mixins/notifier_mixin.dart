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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}