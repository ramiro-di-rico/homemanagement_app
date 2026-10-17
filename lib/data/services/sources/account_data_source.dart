import 'package:home_management_app/domain/models/account.dart';

abstract interface class AccountDataSource {
  /// Balance included.
  Future<List<AccountModel>> fetchAccounts();

  /// Returns the created account, with its real id.
  Future<AccountModel> add(AccountModel account);

  Future update(AccountModel account);

  /// Throws [AccountHasTransactionsException] when the account still has transactions.
  Future delete(AccountModel account);
}

class AccountHasTransactionsException implements Exception {
  @override
  String toString() => 'AccountHasTransactionsException';
}
