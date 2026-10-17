import 'package:home_management_app/data/models/transaction-with-balance.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

abstract interface class TransactionDataSource {
  /// Most recent first: date descending, then id descending.
  Future<List<TransactionModel>> page(TransactionPageModel page);

  Future<List<TransactionModel>> pageNameFiltering(
      TransactionPageModel page, String name);

  /// Local implementation returns the most recent transactions with distinct names.
  Future<List<TransactionModel>> suggested();

  /// The result carries the source account with its post-insert balance.
  Future<TransactionWithBalanceModel> add(TransactionModel transaction);

  Future update(TransactionModel transaction);

  Future delete(int id);
}
