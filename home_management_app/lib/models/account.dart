class AccountModel{

  int id, currencyId, userId;
  String name;
  double balance;
  bool measurable;
  AccountType accountType;

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

  String accountTypeToString(){
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

enum AccountType{
  Cash,
  BankAccount
}