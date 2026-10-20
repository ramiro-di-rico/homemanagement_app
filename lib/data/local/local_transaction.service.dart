import 'package:drift/drift.dart';
import 'package:home_management_app/data/models/transaction-with-balance.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

import 'local_database.dart';
import 'local_write_guard.dart';
import 'local_mappers.dart';

class LocalTransactionService implements TransactionDataSource {
  final LocalDatabase _db;

  LocalTransactionService(this._db);

  @override
  Future<List<TransactionModel>> page(TransactionPageModel page) =>
      _page(page, null);

  @override
  Future<List<TransactionModel>> pageNameFiltering(
          TransactionPageModel page, String name) =>
      _page(page, name);

  Future<List<TransactionModel>> _page(
      TransactionPageModel page, String? name) async {
    final query = _db.select(_db.transactions).join([
      innerJoin(_db.categories,
          _db.categories.id.equalsExp(_db.transactions.categoryId)),
    ])
      ..where(_db.transactions.accountId.equals(page.accountId))
      ..orderBy([
        OrderingTerm.desc(_db.transactions.date),
        OrderingTerm.desc(_db.transactions.id),
      ])
      ..limit(page.pageCount, offset: (page.currentPage - 1) * page.pageCount);
    if (name != null && name.isNotEmpty) {
      // `LIKE` ignores case for ASCII only, so "útil" doesn't find "ÚTIL". That is a
      // known limit of SQLite without ICU, and applies to later pages only: the
      // first page is filtered in memory by `TransactionRepository`.
      // `contains` doesn't escape, so `%` and `_` typed by the user would act as wildcards.
      final escaped = name.replaceAllMapped(
          RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
      query.where(
          _db.transactions.name.like('%$escaped%', escapeChar: '\\'));
    }
    final rows = await query.get();
    return rows
        .map((r) => r
            .readTable(_db.transactions)
            .toModel(r.readTable(_db.categories).name))
        .toList();
  }

  /// The 10 most recent transactions with distinct names.
  @override
  Future<List<TransactionModel>> suggested() async {
    final rows = await _db.customSelect(
      'SELECT t.*, c.name AS category_name FROM transactions t '
      'JOIN categories c ON c.id = t.category_id '
      'WHERE t.id IN (SELECT MAX(id) FROM transactions GROUP BY name) '
      'ORDER BY t.date DESC, t.id DESC LIMIT 10',
      readsFrom: {_db.transactions, _db.categories},
    ).get();
    return rows
        .map((r) => _db.transactions
            .map(r.data)
            .toModel(r.read<String>('category_name')))
        .toList();
  }

  /// There is no transfer mirroring locally, so `targetAccount` is always null.
  @override
  Future<TransactionWithBalanceModel> add(TransactionModel transaction) =>
      guardedTransaction(_db, () async {
    final name = _validate(transaction);
    final id = await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            name: name,
            amount: transaction.amount,
            transactionType: _typeToInt(transaction.transactionType),
            date: toStoredDate(transaction.date),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    final row = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final category = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(row.categoryId)))
        .getSingle();
    final account = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(row.accountId)))
        .getSingle();
    return TransactionWithBalanceModel(row.toModel(category.name),
        account.toModel(await _db.accountBalance(account.id)), null);
  });

  @override
  Future update(TransactionModel transaction) => guardedTransaction(_db, () async {
    final name = _validate(transaction);
    await (_db.update(_db.transactions)
          ..where((t) => t.id.equals(transaction.id)))
        .write(TransactionsCompanion(
      accountId: Value(transaction.accountId),
      categoryId: Value(transaction.categoryId),
      name: Value(name),
      amount: Value(transaction.amount),
      transactionType: Value(_typeToInt(transaction.transactionType)),
      date: Value(toStoredDate(transaction.date)),
    ));
  });

  @override
  Future delete(int id) => guardedTransaction(_db, () async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  });

  int _typeToInt(TransactionType type) =>
      type == TransactionType.Income ? 0 : 1;

  String _validate(TransactionModel transaction) {
    final name = transaction.name.trim();
    if (name.isEmpty || name.length > 200) {
      throw ArgumentError.value(
          transaction.name, 'name', 'must be 1 to 200 characters');
    }
    if (!(transaction.amount > 0)) {
      throw ArgumentError.value(
          transaction.amount, 'amount', 'must be greater than 0');
    }
    return name;
  }
}
