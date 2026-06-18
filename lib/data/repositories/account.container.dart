import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';

class AccountContainer {
  AccountModel account;
  List<TransactionModel> transactions = List.empty(growable: true);

  AccountContainer(this.account);
}
