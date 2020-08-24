import 'package:home_management_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore{
  UserModel userModel;
  String emailKey = 'email';
  String passwordKey = 'password';
  String tokenKey = 'token';
  SharedPreferences preferences;

  UserStore(){
    init();
  }

  void init() async {
    preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey(emailKey) &&
        preferences.containsKey(passwordKey) &&
        preferences.containsKey(tokenKey)){
      userModel = new UserModel(
          preferences.getString(emailKey),
          preferences.getString(passwordKey),
          preferences.getString(tokenKey));
    }
  }

  void store(UserModel user){
    this.userModel = user;
    preferences.setString(emailKey, this.userModel.email);
    preferences.setString(passwordKey, this.userModel.password);
    preferences.setString(tokenKey, this.userModel.token);
  }
}