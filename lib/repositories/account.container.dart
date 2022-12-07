import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/transaction.dart';

class AccountContainer {
  AccountModel account;
  List<TransactionModel> transactions = List.empty(growable: true);

  AccountContainer(this.account);
}
