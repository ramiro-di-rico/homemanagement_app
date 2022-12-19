import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/transaction.dart';

class TransactionWithBalanceModel {
  TransactionModel transactionModel;
  AccountModel sourceAccount;
  AccountModel targetAccount;

  TransactionWithBalanceModel(
      this.transactionModel, this.sourceAccount, this.targetAccount);

  factory TransactionWithBalanceModel.fromJson(dynamic json) {
    return TransactionWithBalanceModel(
        TransactionModel.fromJson(json['transaction']),
        AccountModel.fromJson(json['sourceAccount']),
        AccountModel.fromJson(json['targetAccount']));
  }
}
