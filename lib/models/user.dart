class UserModel{

  final String email, password, token;
  DateTime expirationDate;

  UserModel(this.email, this.password, this.token, this.expirationDate);

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(json['email'], json['password'], json['token'], DateTime.parse(json['expirationDate']));
  }

}