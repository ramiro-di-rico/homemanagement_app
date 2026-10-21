import 'package:home_management_app/domain/models/transaction.dart';

/// The two server calls the transaction step needs, behind an interface so the
/// import can be tested without HTTP.
abstract interface class BulkTransactionClient {
  /// One atomic request. `accountId` and `categoryId` are server ids.
  Future<void> bulkAdd(List<TransactionModel> transactions);

  /// Whether the server account already has at least one transaction. Used after
  /// an ambiguous failure, to avoid sending the same account twice.
  Future<bool> hasTransactions(int serverAccountId);
}
