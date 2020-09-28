import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/email-textfield.dart';
import 'package:home_management_app/custom/components/password-textfield.dart';
import 'package:home_management_app/custom/keyboard.factory.dart';
import 'package:home_management_app/repositories/user.repository.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:local_auth/local_auth.dart';
import '../main/home.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool passwordFieldEnabled = false;
  bool enableButton = false;
  bool isEmailValid = false;
  bool hidePassword = true;
  bool hideRegistrationLabel = false;
  Function buttonPressed = null;
  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();
  UserRepository userRepository = GetIt.instance<UserRepository>();
  KeyboardFactory keyboardFactory;
  final LocalAuthentication auth = LocalAuthentication();

  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    loadUser();
  }

  Future loadUser() async {
    await userRepository.load();
    authenticationService.init();

    if (authenticationService.canAutoAuthenticate()) {
      if (!authenticationService.isAuthenticated()) {
        var biometricsEnabled = await auth.canCheckBiometrics;
        if (biometricsEnabled) {
          var biometricAuthenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Scan your fingerprint to authenticate',
              useErrorDialogs: true,
              stickyAuth: true);
          if (biometricAuthenticated) {
            await this.authenticationService.autoAuthenticate();
          }
        }
      }
      Navigator.popAndPushNamed(context, HomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    var controls = [
      buildEmailTextField(),
      buildPasswordTextFied(),
      buildSendButton()
    ];

    if (!keyboardFactory.isKeyboardVisible()) {
      controls.add(buildDivider());
      controls.add(buildRegistrationLabel());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: controls),
      ),
    );
  }

  Padding buildRegistrationLabel() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Text('You don' 't have an account yet ?'),
          FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, RegistrationScreen.id);
            },
            child: Text('Create one'),
          )
        ],
      ),
    );
  }

  Padding buildDivider() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Divider(
        thickness: 2,
      ),
    );
  }

  Padding buildSendButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: FlatButton(
        color: Colors.blueAccent,
        disabledColor: Colors.grey,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.elliptical(20, 20))),
        child: Icon(Icons.send, color: Colors.white),
        onPressed: buttonPressed,
      ),
    );
  }

  Padding buildPasswordTextFied() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: PasswordTextField(
        onTextChanged: onPasswordChanged,
        enablePassword: passwordFieldEnabled),
    );
  }

  Padding buildEmailTextField() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: EmailTextField(
        onTextChanged: onEmailChanged,
      )
    );
  }

  @override
  void deactivate() {
    if (keyboardFactory.isKeyboardVisible()) {
      keyboardFactory.unFocusKeyboard();
    }
    super.deactivate();
  }

  void onEmailChanged(String character) {
    setState(() {
      this.email = character.trim();
      this.isEmailValid = this.email.contains('@');
      this.enableButton = this.email.length > 0;
      this.passwordFieldEnabled = this.email.length > 0 && this.isEmailValid;
    });
  }

  void onPasswordChanged(String character) {
    setState(() {
      this.password = character;
      this.enableButton = this.password.length > 0;

      if (this.enableButton) {
        this.buttonPressed = onButtonPressed;
      }
    });
  }

  void changePasswordVisibility() {
    setState(() {
      this.hidePassword = !this.hidePassword;
    });
  }

  Future<void> onButtonPressed() async {
    var result = await this
        .authenticationService
        .authenticate(this.email, this.password);

    if (!result) {
      showDialog(
          context: this.context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication error.'),
              actions: [
                FlatButton(
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return;
    }

    Navigator.popAndPushNamed(context, HomeScreen.id);
  }
}
