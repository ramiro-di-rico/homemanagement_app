class AccountModel{

  final int id, currencyId, userId;
  final String name;
  final double balance;
  final bool measurable;
  final AccountType accountType;

  AccountModel(this.id, this.name, this.balance, this.measurable, this.accountType, this.currencyId, this.userId);

  factory AccountModel.fromJson(Map<String, dynamic> json){
    return AccountModel(
      json['id'], 
      json['name'], 
      double.parse(json['balance'].toString()),
      json['measurable'],
      json['accountType'] == 0 ? AccountType.Cash : AccountType.BankAccount, 
      json['currencyId'], 
      json['userId']);
  }
}

enum AccountType{
  Cash,
  BankAccount
}