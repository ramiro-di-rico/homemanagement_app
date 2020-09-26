import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository{
  UserModel userModel;
  String emailKey = 'email';
  String passwordKey = 'password';
  String tokenKey = 'token';
  String expirationDateKey = 'expirationDateKey';
  SharedPreferences preferences;

  Future load() async {
    preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey(emailKey) &&
        preferences.containsKey(passwordKey) &&
        preferences.containsKey(tokenKey)){
      userModel = new UserModel(
          preferences.getString(emailKey),
          preferences.getString(passwordKey),
          preferences.getString(tokenKey),
          DateTime.parse(preferences.getString(expirationDateKey)));
    }
  }

  void store(UserModel user){
    this.userModel = user;

    if(preferences.containsKey(emailKey)){
      this.clear();
    }

    preferences.setString(emailKey, this.userModel.email);
    preferences.setString(passwordKey, this.userModel.password);
    preferences.setString(tokenKey, this.userModel.token);
    preferences.setString(expirationDateKey, this.userModel.expirationDate.toString());
  }

  void clear(){
    this.userModel = null;
    preferences.remove(emailKey);
    preferences.remove(passwordKey);
    preferences.remove(tokenKey);
  }
}