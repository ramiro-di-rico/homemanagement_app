import 'package:home_management_app/domain/models/transaction.dart';

/// Supported bank statement layouts. Mirrors the backend `StatementFormat`.
enum StatementFormat { accountStatementCsv }

extension StatementFormatName on StatementFormat {
  /// The name the API binds to, not the Dart one.
  String get apiName => switch (this) {
        StatementFormat.accountStatementCsv => 'AccountStatementCsv',
      };
}

/// How a statement row was tied to an existing transaction. Mirrors the backend `MatchKind`, which
/// travels as an integer, so the values are positional on both sides.
enum MatchKind {
  reference,
  exactDate,
  dateTolerance,

  /// A value this version of the app does not know. Kept separate instead of guessing: claiming a
  /// specific kind would be a silent lie if the backend ever adds or reorders one.
  unknown
}

MatchKind _parseMatchKind(int value) => switch (value) {
      0 => MatchKind.reference,
      1 => MatchKind.exactDate,
      2 => MatchKind.dateTolerance,
      _ => MatchKind.unknown,
    };

/// A movement as reported by the bank.
class StatementRowModel {
  final String reference;
  final String name;
  final double price;
  final DateTime date;
  final TransactionType transactionType;

  StatementRowModel({
    required this.reference,
    required this.name,
    required this.price,
    required this.date,
    required this.transactionType,
  });

  factory StatementRowModel.fromJson(dynamic json) => StatementRowModel(
        reference: json['reference'],
        name: json['name'],
        price: double.parse(json['price'].toString()),
        date: DateTime.parse(json['date']),
        transactionType:
            TransactionModel.parse(json['transactionType'], categoryName: ''),
      );

  bool isIncome() => transactionType == TransactionType.Income;
}

/// Period balances declared by the statement.
class StatementBalancesModel {
  final double initialBalance;
  final double credits;
  final double debits;
  final double finalBalance;

  StatementBalancesModel({
    required this.initialBalance,
    required this.credits,
    required this.debits,
    required this.finalBalance,
  });

  factory StatementBalancesModel.fromJson(dynamic json) =>
      StatementBalancesModel(
        initialBalance: double.parse(json['initialBalance'].toString()),
        credits: double.parse(json['credits'].toString()),
        debits: double.parse(json['debits'].toString()),
        finalBalance: double.parse(json['finalBalance'].toString()),
      );
}

/// A statement row already present in the app.
class ReconciliationMatchedModel {
  final StatementRowModel row;
  final int transactionId;
  final MatchKind matchKind;

  /// True when applying has to persist the reference on the transaction.
  final bool requiresReferenceLink;

  ReconciliationMatchedModel({
    required this.row,
    required this.transactionId,
    required this.matchKind,
    required this.requiresReferenceLink,
  });

  factory ReconciliationMatchedModel.fromJson(dynamic json) =>
      ReconciliationMatchedModel(
        row: StatementRowModel.fromJson(json['row']),
        transactionId: json['transactionId'],
        matchKind: _parseMatchKind(json['matchKind']),
        requiresReferenceLink: json['requiresReferenceLink'] ?? false,
      );
}

/// A statement row with no counterpart in the app: a transaction to create.
class ReconciliationMissingModel {
  final StatementRowModel row;

  /// Category of the most recent transaction with an equivalent description, when there is one.
  /// Null means the user has to pick one.
  final int? suggestedCategoryId;

  ReconciliationMissingModel({required this.row, this.suggestedCategoryId});

  factory ReconciliationMissingModel.fromJson(dynamic json) =>
      ReconciliationMissingModel(
        row: StatementRowModel.fromJson(json['row']),
        suggestedCategoryId: json['suggestedCategoryId'],
      );
}

/// A statement row that could be more than one transaction. Only the user can resolve it.
class ReconciliationAmbiguousModel {
  final StatementRowModel row;
  final List<int> candidateTransactionIds;
  final int? suggestedCategoryId;

  ReconciliationAmbiguousModel({
    required this.row,
    required this.candidateTransactionIds,
    this.suggestedCategoryId,
  });

  factory ReconciliationAmbiguousModel.fromJson(dynamic json) =>
      ReconciliationAmbiguousModel(
        row: StatementRowModel.fromJson(json['row']),
        candidateTransactionIds:
            ((json['candidateTransactionIds'] as List?) ?? const [])
                .map((e) => e as int)
                .toList(),
        suggestedCategoryId: json['suggestedCategoryId'],
      );
}

/// A transaction the bank does not report inside the period: a candidate for deletion.
class ReconciliationExtraModel {
  final TransactionModel transaction;

  /// True when the transaction is close enough to a period edge that the neighbouring statement may be
  /// the one reporting it. Deleting it on this statement's word alone would be wrong.
  final bool nearPeriodEdge;

  ReconciliationExtraModel({
    required this.transaction,
    required this.nearPeriodEdge,
  });

  factory ReconciliationExtraModel.fromJson(dynamic json) =>
      ReconciliationExtraModel(
        transaction: TransactionModel.fromJson(json['transaction']),
        nearPeriodEdge: json['nearPeriodEdge'] ?? false,
      );
}

class ReconciliationPreviewModel {
  final int accountId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final StatementBalancesModel? statementBalances;
  final List<ReconciliationMatchedModel> matched;
  final List<ReconciliationMissingModel> missing;

  /// Transactions the bank does not report inside the period: candidates for deletion.
  final List<ReconciliationExtraModel> extra;
  final List<ReconciliationAmbiguousModel> ambiguous;

  ReconciliationPreviewModel({
    required this.accountId,
    this.periodStart,
    this.periodEnd,
    this.statementBalances,
    required this.matched,
    required this.missing,
    required this.extra,
    required this.ambiguous,
  });

  factory ReconciliationPreviewModel.fromJson(dynamic json) =>
      ReconciliationPreviewModel(
        accountId: json['accountId'],
        periodStart: json['periodStart'] == null
            ? null
            : DateTime.parse(json['periodStart']),
        periodEnd:
            json['periodEnd'] == null ? null : DateTime.parse(json['periodEnd']),
        statementBalances: json['statementBalances'] == null
            ? null
            : StatementBalancesModel.fromJson(json['statementBalances']),
        matched: _mapList(json['matched'], ReconciliationMatchedModel.fromJson),
        missing: _mapList(json['missing'], ReconciliationMissingModel.fromJson),
        extra: _mapList(json['extra'], ReconciliationExtraModel.fromJson),
        ambiguous:
            _mapList(json['ambiguous'], ReconciliationAmbiguousModel.fromJson),
      );

  /// Extras the user is expected to act on. Rows flagged near a period edge are excluded: they are
  /// most likely owned by the neighbouring statement, and the advice on them is to leave them alone.
  List<ReconciliationExtraModel> get actionableExtra =>
      extra.where((e) => !e.nearPeriodEdge).toList();

  bool get isFullyReconciled =>
      missing.isEmpty && actionableExtra.isEmpty && ambiguous.isEmpty;

  int get pendingCount =>
      missing.length + actionableExtra.length + ambiguous.length;
}

/// A transaction to create out of a statement row.
class ReconciliationTransactionToCreate {
  final String name;
  final double price;
  final DateTime date;
  final TransactionType transactionType;
  final int categoryId;
  final String? externalReference;

  ReconciliationTransactionToCreate({
    required this.name,
    required this.price,
    required this.date,
    required this.transactionType,
    required this.categoryId,
    this.externalReference,
  });

  /// Builds the creation out of a missing row, once a category has been decided.
  factory ReconciliationTransactionToCreate.fromRow(
    StatementRowModel row,
    int categoryId,
  ) =>
      ReconciliationTransactionToCreate(
        name: row.name,
        price: row.price,
        date: row.date,
        transactionType: row.transactionType,
        categoryId: categoryId,
        externalReference: row.reference,
      );

  Map toJson() => {
        'name': name,
        'price': price,
        'date': date.toIso8601String(),
        'transactionType': transactionType == TransactionType.Income ? 0 : 1,
        'categoryId': categoryId,
        'externalReference': externalReference,
      };
}

/// Persists the bank reference on a transaction that was matched heuristically.
class ReconciliationReferenceLink {
  final int transactionId;
  final String externalReference;

  ReconciliationReferenceLink({
    required this.transactionId,
    required this.externalReference,
  });

  Map toJson() => {
        'transactionId': transactionId,
        'externalReference': externalReference,
      };
}

/// How far the account balance ends up from the statement's final balance.
class BalanceCheckModel {
  final double expected;
  final double actual;
  final double difference;
  final bool matches;

  /// Date [actual] refers to. Null means today, which only compares fairly when the statement
  /// period ends today.
  final DateTime? asOf;

  BalanceCheckModel({
    required this.expected,
    required this.actual,
    required this.difference,
    required this.matches,
    this.asOf,
  });

  factory BalanceCheckModel.fromJson(dynamic json) => BalanceCheckModel(
        expected: double.parse(json['expected'].toString()),
        actual: double.parse(json['actual'].toString()),
        difference: double.parse(json['difference'].toString()),
        matches: json['matches'] ?? false,
        asOf: json['asOf'] == null ? null : DateTime.parse(json['asOf']),
      );
}

class ApplyReconciliationResultModel {
  final int createdCount;
  final int deletedCount;
  final int linkedCount;
  final BalanceCheckModel? balanceCheck;

  ApplyReconciliationResultModel({
    required this.createdCount,
    required this.deletedCount,
    required this.linkedCount,
    this.balanceCheck,
  });

  factory ApplyReconciliationResultModel.fromJson(dynamic json) =>
      ApplyReconciliationResultModel(
        createdCount: json['createdCount'] ?? 0,
        deletedCount: json['deletedCount'] ?? 0,
        linkedCount: json['linkedCount'] ?? 0,
        balanceCheck: json['balanceCheck'] == null
            ? null
            : BalanceCheckModel.fromJson(json['balanceCheck']),
      );

  int get changedCount => createdCount + deletedCount;
}

List<T> _mapList<T>(dynamic json, T Function(dynamic) map) =>
    ((json as List?) ?? const []).map(map).toList();
