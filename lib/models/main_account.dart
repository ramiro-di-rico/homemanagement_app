import 'account.dart';

class MainAccountModel {
  int id, userId, childAccountCount;
  String name;
  bool isHidden;
  List<AccountModel> childAccounts = [];

  MainAccountModel(this.id, this.name, this.userId, this.childAccountCount, this.isHidden);

  factory MainAccountModel.fromJson(Map<String, dynamic> json) {
    var mainAccount = MainAccountModel(
      json['id'],
      json['name'],
      json['userId'],
      json['childAccountCount'] ?? 0,
      json['isHidden'] ?? false
    );
    
    if (json['childAccounts'] != null) {
      mainAccount.childAccounts = (json['childAccounts'] as List)
          .map((e) => AccountModel.fromJson(e))
          .toList();
    }
    
    return mainAccount;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userId': userId,
    'childAccountCount': childAccountCount,
    'isHidden': isHidden
  };
}
