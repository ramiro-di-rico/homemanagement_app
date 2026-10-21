import 'package:home_management_app/data/services/sources/bulk_transaction_client.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

class RemoteBulkTransactionClient implements BulkTransactionClient {
  final TransactionService _service;

  RemoteBulkTransactionClient(this._service);

  @override
  Future<void> bulkAdd(List<TransactionModel> transactions) =>
      _service.bulkAdd(transactions);

  @override
  Future<bool> hasTransactions(int serverAccountId) async =>
      (await _service.page(
        TransactionPageModel.newPage(serverAccountId, 1, 1),
      )).isNotEmpty;
}
