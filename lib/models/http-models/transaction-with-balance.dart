import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/transaction.dart';

class TransactionWithBalanceModel {
  TransactionModel transactionModel;
  AccountModel sourceAccount;
  AccountModel? targetAccount;

  TransactionWithBalanceModel(
      this.transactionModel, this.sourceAccount, this.targetAccount);

  factory TransactionWithBalanceModel.fromJson(dynamic json) {
    return TransactionWithBalanceModel(
        TransactionModel.fromJson(json['transaction']),
        AccountModel.nameAndBalance(json['sourceAccount']),
        json['targetAccount'] != null
            ? AccountModel.nameAndBalance(json['targetAccount'])
            : null);
  }

  bool isTargetAccountAvailable() {
    return (this.targetAccount?.id ?? 0) > 0;
  }
}
