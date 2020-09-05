import 'package:flutter/material.dart';
import 'package:home_management_app/services/authentication.service.dart';
import 'package:injector/injector.dart';
import '../main/home.dart';

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
  Function buttonPressed = null;
  Injector injector = Injector.appInstance;
  AuthenticationService authenticationService;

  void initState() {
    super.initState();
    this.authenticationService =
        injector.getDependency<AuthenticationService>();
    if (authenticationService.isAuthenticated()) {
      email = authenticationService.user.email;
      password = authenticationService.user.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: createTextField('Email', true, false, onEmailChanged),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: createTextField('Password', this.passwordFieldEnabled, true, onPasswordChanged),
                ),
                Padding(
                  padding: EdgeInsets.all(20),                  
                  child: FlatButton(
                    color: Colors.blueAccent,
                    disabledColor: Colors.grey,
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    shape: RoundedRectangleBorder(),
                    child: Icon(Icons.send, color: Colors.white),
                    onPressed: buttonPressed,                    
                  ),
                )
              ]),
        ),
      ),
    );
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

      if(this.enableButton){
        this.buttonPressed = onButtonPressed;
      }
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

  Widget createTextField(
      String label, bool enabled, bool obscureText, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      obscureText: obscureText,
      enabled: enabled,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          labelText: label),
    );
  }
}
