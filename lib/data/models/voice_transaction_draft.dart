import 'package:home_management_app/domain/models/transaction.dart';

/// Draft returned by `POST transactions/voice/preview`. Nothing is saved on the
/// backend; the user reviews it in the add-transaction form.
class VoiceTransactionDraft {
  final String rawTranscription;
  final String name;
  final double amount;
  final DateTime date;
  final TransactionType transactionType;
  final int categoryId;
  final int accountId;
  final bool isCategoryInferred;

  VoiceTransactionDraft({
    required this.rawTranscription,
    required this.name,
    required this.amount,
    required this.date,
    required this.transactionType,
    required this.categoryId,
    required this.accountId,
    required this.isCategoryInferred,
  });

  factory VoiceTransactionDraft.fromJson(Map<String, dynamic> json) =>
      VoiceTransactionDraft(
        rawTranscription: json['rawTranscription'] ?? '',
        name: json['name'] ?? '',
        amount: double.parse((json['amount'] ?? json['price']).toString()),
        date: DateTime.parse(json['date']),
        transactionType: TransactionModel.parse(json['transactionType'],
            categoryName: json['categoryName']),
        categoryId: json['categoryId'],
        accountId: json['accountId'],
        isCategoryInferred: json['isCategoryInferred'] ?? false,
      );
}
