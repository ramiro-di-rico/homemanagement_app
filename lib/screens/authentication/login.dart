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
  bool isAuthenticating = false;
  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();
  UserRepository userRepository = GetIt.instance<UserRepository>();
  KeyboardFactory keyboardFactory;
  final LocalAuthentication auth = LocalAuthentication();

  void initState() {
    super.initState();
    this.keyboardFactory = KeyboardFactory(context: context);
    this.authenticationService.addListener(successFullAuthentcation);
    loadUser();
  }

  Future loadUser() async {
    await authenticationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: EmailTextField(
                    onTextChanged: onEmailChanged,
                    enableEmailField: !isAuthenticating,
                  )),
              Padding(
                padding: EdgeInsets.all(20),
                child: PasswordTextField(
                    onTextChanged: onPasswordChanged,
                    enablePassword: passwordFieldEnabled && !isAuthenticating),
              ),
              isAuthenticating
                  ? Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: ElevatedButton(
                            child: Icon(Icons.send, color: Colors.white),
                            onPressed: onButtonPressed,
                          ),
                        ),
                        ElevatedButton(
                            onPressed:
                                authenticationService.biometricsAuthenticate,
                            child: Icon(Icons.fingerprint))
                      ],
                    ),
            ],
          ),
          Column(
            children: keyboardFactory.isKeyboardVisible()
                ? []
                : [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Text('You don' 't have an account yet ?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RegistrationScreen.id);
                            },
                            child: Text('Create one'),
                          )
                        ],
                      ),
                    )
                  ],
          )
        ]),
      ),
    );
  }

  void onEmailChanged(String character) {
    setState(() {
      this.email = character.trim();
      this.isEmailValid = this.email.contains('@');
      this.passwordFieldEnabled = this.email.length > 0 && this.isEmailValid;
    });
  }

  void onPasswordChanged(String character) {
    setState(() {
      this.password = character;
      this.enableButton = this.password.length > 0;
    });
  }

  bool canLogin() {
    return this.email.length > 0 && this.password.length > 0;
  }

  void changePasswordVisibility() {
    setState(() {
      this.hidePassword = !this.hidePassword;
    });
  }

  Future<void> onButtonPressed() async {
    if (!this.canLogin()) {
      return;
    }
    setState(() {
      isAuthenticating = true;
    });

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
                TextButton(
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      setState(() {
        isAuthenticating = false;
      });
      return;
    }
  }

  void successFullAuthentcation() {
    Navigator.popAndPushNamed(context, HomeScreen.id);
  }
}
