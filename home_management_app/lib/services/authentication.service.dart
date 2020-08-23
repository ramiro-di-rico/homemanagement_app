import 'package:home_management_app/models/user.dart';

class AuthenticationService{

  UserModel user;

  bool isAuthenticated(){
    return user != null;
  }

  void authenticate(String email, String password){
    this.user = new UserModel();
    this.user.email = email;
    this.user.password = password;
  }
}