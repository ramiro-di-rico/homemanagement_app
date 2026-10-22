import 'package:drift/drift.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/local_record_not_found_exception.dart';
import 'package:home_management_app/domain/models/account.dart';

import 'local_database.dart';
import 'local_write_guard.dart';
import 'local_mappers.dart';

class LocalAccountService implements AccountDataSource {
  final LocalDatabase _db;

  LocalAccountService(this._db);

  @override
  Future<List<AccountModel>> fetchAccounts() => guardRead(() async {
    final rows = await _db.customSelect(
      'SELECT a.*, ${balanceSql(alias: 't')} AS balance '
      'FROM accounts a LEFT JOIN transactions t ON t.account_id = a.id '
      'GROUP BY a.id ORDER BY a.id',
      readsFrom: {_db.accounts, _db.transactions},
    ).get();
    return rows
        .map((row) => _db.accounts
            .map(row.data)
            .toModel(row.read<double>('balance')))
        .toList();
  });

  @override
  Future<AccountModel> add(AccountModel account) => guardedTransaction(_db, () async {
    final name = validName(account.name);
    final id = await _db.into(_db.accounts).insert(AccountsCompanion.insert(
          name: name,
          accountType: accountTypeToInt(account.accountType),
          currencyId: account.currencyId,
          measurable: Value(account.measurable),
          archive: Value(account.archive),
          isHidden: Value(account.isHidden),
        ));
    final created = await (_db.select(_db.accounts)
          ..where((a) => a.id.equals(id)))
        .getSingle();
    return created.toModel(0);
  });

  @override
  Future update(AccountModel account) => guardedTransaction(_db, () async {
    final name = validName(account.name);
    final changed = await (_db.update(_db.accounts)
          ..where((a) => a.id.equals(account.id)))
        .write(AccountsCompanion(
      name: Value(name),
      accountType: Value(accountTypeToInt(account.accountType)),
      currencyId: Value(account.currencyId),
      measurable: Value(account.measurable),
      archive: Value(account.archive),
      isHidden: Value(account.isHidden),
    ));
    if (changed == 0) throw LocalRecordNotFoundException('account', account.id);
  });

  /// Deleting one that is already gone is not an error: the account is not there,
  /// which is what was asked for.
  @override
  Future delete(AccountModel account) => guardedTransaction(_db, () async {
    final used = await (_db.select(_db.transactions)
          ..where((t) => t.accountId.equals(account.id))
          ..limit(1))
        .get();
    if (used.isNotEmpty) throw AccountHasTransactionsException();
    await (_db.delete(_db.accounts)..where((a) => a.id.equals(account.id)))
        .go();
  });
}
