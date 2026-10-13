import 'package:home_management_app/domain/models/transaction.dart';

/// One item from `POST transactions/document/preview`: either a draft or an
/// error, one per uploaded file. Nothing is saved on the backend; the user
/// reviews the result in the add-transaction form.
class DocumentTransactionPreview {
  final String fileName;
  final DocumentTransactionDraft? draft;
  final String? error;

  DocumentTransactionPreview({required this.fileName, this.draft, this.error});

  factory DocumentTransactionPreview.fromJson(Map<String, dynamic> json) =>
      DocumentTransactionPreview(
        fileName: json['fileName'] ?? '',
        draft: json['draft'] == null
            ? null
            : DocumentTransactionDraft.fromJson(json['draft']),
        error: json['error'],
      );

  static List<DocumentTransactionPreview> listFromJson(
          Map<String, dynamic> json) =>
      (json['documents'] as List)
          .map((e) => DocumentTransactionPreview.fromJson(e))
          .toList();
}

class DocumentTransactionDraft {
  final String rawText;
  final String name;
  final double amount;
  final DateTime date;
  final TransactionType transactionType;
  final int categoryId;
  final String categoryName;
  final int accountId;
  final bool isCategoryInferred;

  DocumentTransactionDraft({
    required this.rawText,
    required this.name,
    required this.amount,
    required this.date,
    required this.transactionType,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    required this.isCategoryInferred,
  });

  factory DocumentTransactionDraft.fromJson(Map<String, dynamic> json) =>
      DocumentTransactionDraft(
        rawText: json['rawText'] ?? '',
        name: json['name'] ?? '',
        amount: double.parse(json['amount'].toString()),
        date: DateTime.parse(json['date']),
        transactionType: TransactionModel.parse(json['transactionType'],
            categoryName: json['categoryName']),
        categoryId: json['categoryId'],
        categoryName: json['categoryName'] ?? '',
        accountId: json['accountId'],
        isCategoryInferred: json['isCategoryInferred'] ?? false,
      );
}
