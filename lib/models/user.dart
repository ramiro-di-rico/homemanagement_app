import 'view-models/user-view-model.dart';

class UserModel {
  final String email, username, password, token;
  DateTime expirationDate;

  UserModel(this.email, this.username, this.password, this.token,
      this.expirationDate);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(json['email'], json['username'], json['password'],
        json['token'], DateTime.parse(json['expirationDate']));
  }

  factory UserModel.fromViewModel(UserViewModel userViewModel) {
    return UserModel(userViewModel.email, '', userViewModel.password, '', DateTime.now());
  }
}
