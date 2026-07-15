class MyUserViewModel {
  final String? id;
  final String? email;
  final String? username;
  final bool? active;
  final String? language;
  final String? timeZone;
  final int? digestFrequency;
  final String? preferredSendTime;

  MyUserViewModel({
    this.id,
    this.email,
    this.username,
    this.active,
    this.language,
    this.timeZone,
    this.digestFrequency,
    this.preferredSendTime,
  });

  static Future<MyUserViewModel> fromJson(Map<String, dynamic> jsonModel) {
    return Future.value(
      MyUserViewModel(
        id: jsonModel['id'],
        email: jsonModel['email'],
        username: jsonModel['username'],
        active: jsonModel['active'],
        language: jsonModel['language'],
        timeZone: jsonModel['timeZone'],
        digestFrequency: jsonModel['digestFrequency'],
        preferredSendTime: jsonModel['preferredSendTime'],
      ),
    );
  }
}
