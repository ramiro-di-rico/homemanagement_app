class UserModel{

  final String email, password, token;

  UserModel(this.email, this.password, this.token);

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(json['email'], json['password'], json['token']);
  }

}