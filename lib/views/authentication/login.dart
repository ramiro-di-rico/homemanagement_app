import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/custom/components/email-textfield.dart';
import 'package:home_management_app/custom/components/password-textfield.dart';
import 'package:home_management_app/custom/keyboard.factory.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/services/security/authentication.service.dart';
import '../../models/view-models/user-view-model.dart';
import '../main/home.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserViewModel userViewModel = UserViewModel();
  bool hidePassword = true;
  bool hideRegistrationLabel = false;
  bool isAuthenticating = false;
  UserModel user = UserModel('', '', '', '', DateTime.now());
  AuthenticationService authenticationService =
      GetIt.instance<AuthenticationService>();
  KeyboardFactory? keyboardFactory;

  void initState() {
    super.initState();
    authenticationService.addListener((){
      setAuthenticatingStatus(authenticationService.isAuthenticating);
    });
    this.keyboardFactory = KeyboardFactory(context: context);
    loadUser();
  }

  Future loadUser() async {
    if (await authenticationService.init()) {
      await successFullAuthentication();
    }
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
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: PasswordTextField(
                    onTextChanged: onPasswordChanged,
                    enablePassword: userViewModel.isEmailValid && !isAuthenticating),
              ),
              isAuthenticating
                  ? Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator())
                  : ElevatedButton(
                      child: Icon(Icons.send, color: Colors.white),
                      onPressed: userViewModel.isValid ? onButtonPressed : null,
                    ),
            ],
          ),
          Column(
            children: keyboardFactory?.isKeyboardVisible() ?? false
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
      this.userViewModel.email = character.trim();
    });
  }

  void onPasswordChanged(String character) {
    setState(() {
      this.userViewModel.password = character;
    });
  }

  void changePasswordVisibility() {
    setState(() {
      this.hidePassword = !this.hidePassword;
    });
  }

  Future<void> onButtonPressed() async {
    if (!this.userViewModel.isValid) {
      return;
    }

    setAuthenticatingStatus(true);

    var authenticatedSuccessfully = await this
        .authenticationService
        .authenticate(this.userViewModel);

    setAuthenticatingStatus(false);

    if (authenticatedSuccessfully){
      await successFullAuthentication();
    } else {
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
    }
  }

  void setAuthenticatingStatus(bool status) {
    setState(() {
      this.isAuthenticating = status;
    });
  }

  Future successFullAuthentication() async {
    await Navigator.popAndPushNamed(context, HomeScreen.id);
  }
}
