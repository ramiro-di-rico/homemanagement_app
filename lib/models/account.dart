class AccountModel {
  int id, currencyId, userId;
  String name;
  double balance;
  bool measurable;
  AccountType accountType;
  bool archive;
  bool isHidden;

  AccountModel(this.id, this.name, this.balance, this.measurable,
      this.accountType, this.currencyId, this.userId, this.archive, this.isHidden);

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
        json['id'],
        json['name'],
        double.parse(json['balance'].toString()),
        json['measurable'],
        json['accountType'] == 0 ? AccountType.Cash : AccountType.BankAccount,
        json['currencyId'],
        json['userId'],
        json['archive'],
        json['isHidden']);
  }

  factory AccountModel.nameAndBalance(Map<String, dynamic> json) =>
      AccountModel(
          json['id'],
          json['name'],
          double.parse(json['balance'].toString()),
          false,
          AccountType.Cash,
          0,
          0,
          false,
          false);

  factory AccountModel.empty(int currencyId) =>
      AccountModel(0, "", 0, false, AccountType.Cash, currencyId, 0, false, false);

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': id,
        'name': name,
        'balance': balance,
        'measurable': measurable,
        'accountType': accountType == AccountType.Cash ? 0 : 1,
        'currencyId': currencyId,
        'userId': userId,
        'archive': archive,
        'isHidden': isHidden
      };

  String accountTypeToString() {
    switch (this.accountType) {
      case AccountType.Cash:
        return 'Cash';
      case AccountType.BankAccount:
        return 'Bank Account';
      default:
        return '';
    }
  }
}

enum AccountType { Cash, BankAccount }
