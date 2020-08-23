import 'package:flutter/material.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:injector/injector.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  Injector injector = Injector.appInstance;
  AuthenticationService authenticationService;

  void initState() {
    super.initState();
    this.authenticationService = injector.getDependency<AuthenticationService>();
    print(this.authenticationService.isAuthenticated());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
