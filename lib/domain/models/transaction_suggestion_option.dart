import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';

abstract class TransactionSuggestionOption {
  String get name;
}

class TransactionModelOption extends TransactionSuggestionOption {
  final TransactionModel transaction;
  TransactionModelOption(this.transaction);
  @override
  String get name => transaction.name;
}

class AccountModelOption extends TransactionSuggestionOption {
  final AccountModel account;
  AccountModelOption(this.account);
  @override
  String get name => account.name;
}
