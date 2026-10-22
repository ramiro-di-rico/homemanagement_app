import 'package:drift/drift.dart' show Index, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_account.service.dart';
import 'package:home_management_app/data/local/local_category.service.dart';
import 'package:home_management_app/data/local/local_currency.service.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_mappers.dart';
import 'package:home_management_app/data/local/local_transaction.service.dart';
import 'package:home_management_app/data/services/sources/local_read_failed_exception.dart';
import 'package:home_management_app/data/services/sources/local_record_not_found_exception.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

import '../../helpers/storage_failures.dart';

/// The cleanups from the review (RF-19) that change what the data layer does.
void main() {
  late FailingReads failing;
  late LocalDatabase db;
  late LocalAccountService accounts;
  late LocalCategoryService categories;
  late LocalTransactionService transactions;

  setUp(() {
    failing = FailingReads();
    db = openWithFailingReads(failing);
    accounts = LocalAccountService(db);
    categories = LocalCategoryService(db);
    transactions = LocalTransactionService(db);
  });
  tearDown(() => db.close());

  Future<AccountModel> addAccount([String name = 'Main']) => accounts
      .add(AccountModel(0, name, 0, true, AccountType.Cash, 1, 0, false, false));

  group('updating something that is not there', () {
    test('an account says so, instead of succeeding', () async {
      final ghost = AccountModel(999, 'Ghost', 0, true, AccountType.Cash, 1, 0, false, false);

      await expectLater(accounts.update(ghost), throwsA(isA<LocalRecordNotFoundException>()));
    });

    test('a category says so', () async {
      final ghost = CategoryModel(999, 0, 'Ghost', 'home', true, true, '#ffffff');

      await expectLater(categories.update(ghost), throwsA(isA<LocalRecordNotFoundException>()));
    });

    test('a transaction says so', () async {
      final ghost = TransactionModel(
          999, 1, 1, 'Ghost', 5, DateTime(2026, 1, 1), TransactionType.Outcome);

      await expectLater(transactions.update(ghost), throwsA(isA<LocalRecordNotFoundException>()));
    });

    test('one that was deleted since it was loaded is refused, and nothing is recreated', () async {
      final account = await addAccount();
      final loaded = (await accounts.fetchAccounts()).single;
      await accounts.delete(loaded);

      await expectLater(accounts.update(loaded..name = 'Renamed'),
          throwsA(isA<LocalRecordNotFoundException>()));

      expect(await accounts.fetchAccounts(), isEmpty);
      expect(account.id, loaded.id);
    });

    test('a row that exists still updates, even when nothing changes', () async {
      final account = await addAccount();

      await accounts.update(account);
      await accounts.update(account..name = 'Renamed');

      expect((await accounts.fetchAccounts()).single.name, 'Renamed');
    });

    test('deleting something that is already gone is not an error', () async {
      final account = await addAccount();
      await accounts.delete(account);

      await accounts.delete(account);
      await transactions.delete(12345);
      await categories.delete(CategoryModel(999, 0, 'Ghost', 'home', true, true, '#ffffff'));
    });
  });

  group('a read that fails because the storage did', () {
    setUp(() async {
      await addAccount();
      failing.error = diskIoError();
    });

    test('every read says so with a typed error, not a raw database one', () async {
      final page = TransactionPageModel.newPage(1, 1, 10);

      for (final read in <Future Function()>[
        accounts.fetchAccounts,
        categories.fetch,
        LocalCurrencyService(db).fetchCurrencies,
        () => transactions.page(page),
        () => transactions.pageNameFiltering(page, 'x'),
        transactions.suggested,
      ]) {
        await expectLater(read(), throwsA(isA<LocalReadFailedException>()));
      }
    });

    test('an error that is not about the storage is not dressed up as one', () async {
      failing.error = sqlLogicError();

      await expectLater(accounts.fetchAccounts(), throwsA(isA<Exception>().having(
          (e) => e is LocalReadFailedException, 'is a storage failure', isFalse)));
    });

    test('and reading works again once the storage does', () async {
      failing.error = null;

      expect(await accounts.fetchAccounts(), hasLength(1));
    });
  });

  group('the indexes are declared on the tables', () {
    test('drift knows both, so its schema tools and migrations do too', () {
      final names = db.allSchemaEntities.whereType<Index>().map((i) => i.entityName);

      expect(names, containsAll(['categories_name_key', 'transactions_account_date']));
    });

    test('and a new database has them', () async {
      final rows = await db.customSelect(
          "SELECT name, sql FROM sqlite_master WHERE type = 'index' AND name IN "
          "('categories_name_key', 'transactions_account_date')").get();
      final sql = {for (final r in rows) r.read<String>('name'): r.read<String>('sql')};

      expect(sql.keys, unorderedEquals(['categories_name_key', 'transactions_account_date']));
      expect(sql['categories_name_key'], contains('UNIQUE'));
      expect(sql['transactions_account_date'], contains('date DESC'));
    });

    test('the unique one still refuses a second category with the same key', () async {
      await expectLater(
          db.into(db.categories).insert(CategoriesCompanion.insert(
              name: 'rent', icon: 'x', nameKey: Value(categoryNameKey('Rent')))),
          throwsA(anything));
    });

    test('a page of an account\'s transactions is read through its index', () async {
      final plan = await db.customSelect(
          'EXPLAIN QUERY PLAN SELECT * FROM transactions WHERE account_id = 1 '
          'ORDER BY date DESC, id DESC LIMIT 20').get();

      expect(plan.map((r) => r.read<String>('detail')).join(' '),
          contains('transactions_account_date'));
    });
  });

  group('the balance is defined once', () {
    test('the one-account and the every-account queries agree, including with no transactions',
        () async {
      final a = await addAccount('A');
      final b = await addAccount('B');
      final empty = await addAccount('Empty');
      await transactions.add(TransactionModel(0, a.id, 1, 'Pay', 100, DateTime(2026, 1, 1), TransactionType.Income));
      await transactions.add(TransactionModel(0, a.id, 1, 'Bus', 30.5, DateTime(2026, 1, 2), TransactionType.Outcome));
      await transactions.add(TransactionModel(0, b.id, 1, 'Cafe', 7, DateTime(2026, 1, 3), TransactionType.Outcome));

      final all = {for (final x in await accounts.fetchAccounts()) x.id: x.balance};

      for (final id in [a.id, b.id, empty.id]) {
        expect(all[id], closeTo(await db.accountBalance(id), 0.0001), reason: 'account $id');
      }
      expect(all[a.id], closeTo(69.5, 0.0001));
      expect(all[b.id], closeTo(-7, 0.0001));
      expect(all[empty.id], 0);
    });

    test('the expression takes the table alias, if any', () {
      expect(balanceSql(), contains('SUM(CASE transaction_type WHEN 0 THEN amount ELSE -amount END)'));
      expect(balanceSql(alias: 't'), contains('SUM(CASE t.transaction_type WHEN 0 THEN t.amount ELSE -t.amount END)'));
    });
  });

  group('how types and names are stored', () {
    test('the numbers are the server\'s, and read back to the same type', () {
      expect(accountTypeToInt(AccountType.Cash), 0);
      expect(accountTypeToInt(AccountType.BankAccount), 1);
      expect(transactionTypeToInt(TransactionType.Income), 0);
      expect(transactionTypeToInt(TransactionType.Outcome), 1);
      for (final type in AccountType.values) {
        expect(accountTypeFromInt(accountTypeToInt(type)), type);
      }
      for (final type in TransactionType.values) {
        expect(transactionTypeFromInt(transactionTypeToInt(type)), type);
      }
    });

    test('the local numbers match what the models send to the server', () {
      for (final type in AccountType.values) {
        final account = AccountModel(1, 'x', 0, true, type, 1, 0, false, false);
        expect(account.toJson()['accountType'], accountTypeToInt(type));
      }
      for (final type in TransactionType.values) {
        final transaction = TransactionModel(1, 1, 1, 'x', 1, DateTime(2026, 1, 1), type);
        expect(transaction.toJson()['transactionType'], transactionTypeToInt(type));
      }
    });

    test('a name is trimmed and has 1 to 100 characters, for accounts and categories alike', () async {
      expect(validName('  Rent  '), 'Rent');
      expect(validName('x' * 100), hasLength(100));
      expect(() => validName('   '), throwsArgumentError);
      expect(() => validName('x' * 101), throwsArgumentError);

      await expectLater(addAccount('x' * 101), throwsArgumentError);
      await expectLater(
          categories.add(CategoryModel(0, 0, '   ', 'home', true, true, '#ffffff')), throwsArgumentError);
    });
  });
}
