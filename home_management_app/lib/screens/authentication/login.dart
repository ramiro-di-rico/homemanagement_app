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
  Injector injector = Injector.appInstance;
  AuthenticationService authenticationService;

  void initState() {
    super.initState();
    this.authenticationService = injector.getDependency<AuthenticationService>();
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
                  child: createEmailTextField(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: createPasswordTextField(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),                  
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: onButtonPressed,
                  ),
                )
              ]),
        ),
      ),
    );
  }

  void onEmailChanged(String character){
    setState(() {
      this.email = character;
      this.isEmailValid = this.email.contains('@');
      this.enableButton = this.email.length > 0;
      this.passwordFieldEnabled = this.email.length > 0 && this.isEmailValid;      
    });
  }

  void onPasswordChanged(String character){
    setState(() {
      this.password = character;
      this.enableButton = this.password.length > 0;      
    });
  }

  Future<void> onButtonPressed() async{
    var result = await this.authenticationService.authenticate(this.email, this.password);

    if(!result){
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

  Widget createEmailTextField() {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: onEmailChanged,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          labelText: 'Email'),
    );
  }

  Widget createPasswordTextField() {
    return TextField(
      enabled: passwordFieldEnabled,
      onChanged: onPasswordChanged,
      obscureText: true,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          labelText: 'Password'),
    );
  }
}
