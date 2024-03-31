import 'view-models/user-view-model.dart';

class UserModel {
  final String email, username, password, token, refreshToken;
  DateTime expirationDate;
  bool twoFactorRequired;

  UserModel(this.email, this.username, this.password, this.token, this.refreshToken,
      this.expirationDate, this.twoFactorRequired);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var email = json['email'] ?? '';
    var username = json['username'] ?? '';
    var password = json['password'] ?? '';
    var token = json['token'] ?? '';
    var refreshToken = json['refreshToken'] ?? '';
    var expirationDate = DateTime.parse(json['expirationDate']);
    var twoFactorRequired = json['twoFactorRequired'];
    return UserModel(email, username, password, token, refreshToken, expirationDate, twoFactorRequired);
  }

  factory UserModel.fromViewModel(UserViewModel userViewModel) {
    return UserModel(userViewModel.email, '', userViewModel.password, '', '', DateTime.now(), false);
  }
}
