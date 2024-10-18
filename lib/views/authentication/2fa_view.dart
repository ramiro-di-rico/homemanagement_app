import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../services/security/authentication.service.dart';
import '../../views/main/home.dart';

class TwoFactorAuthenticationView extends StatefulWidget {
  static const String fullPath = '/2fa_screen';

  @override
  State<TwoFactorAuthenticationView> createState() => _TwoFactorAuthenticationViewState();
}

class _TwoFactorAuthenticationViewState extends State<TwoFactorAuthenticationView> {
  AuthenticationService authenticationService = GetIt.instance<AuthenticationService>();
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Two Factor Authentication'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    onChanged: (value) {
                      code = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter the code',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Icon(Icons.send, color: Colors.white),
                  onPressed: completeTwoFactorAuthentication,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future completeTwoFactorAuthentication() async {
    var result = await authenticationService.completeTwoFactorAuthentication(code);

    if (result) {
      //Navigator.popUntil(context, (route) => HomeScreen.id == route.settings.name);
      context.pop();
      context.go(HomeScreen.fullPath);
    }
  }
}
