class MyUserViewModel{
  final String? id;
  final String? email;
  final String? username;
  final bool? active;
  final String? language;

  MyUserViewModel({this.id, this.email, this.username, this.active, this.language});

  static Future<MyUserViewModel> fromJson(Map<String, dynamic> jsonModel) {
    return Future.value(MyUserViewModel(
      id: jsonModel['id'],
      email: jsonModel['email'],
      username: jsonModel['username'],
      active: jsonModel['active'],
      language: jsonModel['language'],
    ));
  }
}