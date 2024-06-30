import '../../../models/transaction.dart';

mixin class TransactionListSkeletonBehavior {
  final String skeletonName = 'skeleton';
  List<TransactionModel> transactions = [];

  void addSkeletonTransactions() {
    for (var i = 0; i < 10; i++) {
      transactions.add(TransactionModel(
          0, 0, 0, skeletonName, 99999, DateTime.now(), TransactionType.Income));
    }
  }
}