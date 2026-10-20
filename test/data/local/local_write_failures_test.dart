import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_account.service.dart';
import 'package:home_management_app/data/local/local_category.service.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_transaction.service.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';

import '../../helpers/storage_failures.dart';

final Matcher throwsWriteFailed = throwsA(isA<LocalWriteFailedException>());

void main() {
  late LocalDatabase db;
  late LocalAccountService accounts;
  late LocalCategoryService categories;
  late LocalTransactionService transactions;
  late AccountModel account;
  late CategoryModel category;
  late TransactionModel transaction;

  AccountModel newAccount() =>
      AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false);
  TransactionModel newTransaction(int accountId, {String name = 'Item'}) =>
      TransactionModel(0, accountId, 1, name, 10, DateTime(2026, 1, 1), TransactionType.Outcome);

  Future<void> setUpData(LocalDatabase database) async {
    db = database;
    accounts = LocalAccountService(db);
    categories = LocalCategoryService(db);
    transactions = LocalTransactionService(db);
    account = await accounts.add(newAccount());
    category = await categories.add(CategoryModel(0, 0, 'Pets', 'pets', true, true, '#ffffff'));
    transaction = (await transactions.add(newTransaction(account.id))).transactionModel;
  }

  setUp(() => setUpData(LocalDatabase(NativeDatabase.memory())));
  tearDown(() => db.close());

  group('a failing write is reported as LocalWriteFailedException', () {
    test('for accounts', () async {
      await makeStorageReadOnly(db);

      await expectLater(accounts.add(newAccount()), throwsWriteFailed);
      account.name = 'Renamed';
      await expectLater(accounts.update(account), throwsWriteFailed);
      final empty = await (db.select(db.accounts)..where((a) => a.id.equals(account.id))).getSingle();
      expect(empty.name, 'Main', reason: 'nothing was saved');
    });

    test('for categories', () async {
      await makeStorageReadOnly(db);

      await expectLater(
          categories.add(CategoryModel(0, 0, 'Other', 'x', true, true, '#ffffff')), throwsWriteFailed);
      await expectLater(categories.update(category), throwsWriteFailed);
      await expectLater(categories.delete(category), throwsWriteFailed);
      expect(await categories.fetch(), hasLength(18));
    });

    test('for transactions', () async {
      await makeStorageReadOnly(db);

      await expectLater(transactions.add(newTransaction(account.id)), throwsWriteFailed);
      await expectLater(transactions.update(transaction), throwsWriteFailed);
      await expectLater(transactions.delete(transaction.id), throwsWriteFailed);
      expect((await accounts.fetchAccounts()).single.balance, closeTo(-10, 0.001));
    });

    test('deleting an account whose row cannot be removed', () async {
      final empty = await accounts.add(newAccount());
      await makeStorageReadOnly(db);

      await expectLater(accounts.delete(empty), throwsWriteFailed);
    });
  });

  test('a full disk is reported too, and keeps the original SQLite error', () async {
    final pages = await db.customSelect('PRAGMA page_count').getSingle();
    await db.customStatement('PRAGMA max_page_count = ${pages.read<int>('page_count')}');

    Object? failure;
    for (var i = 0; i < 5000 && failure == null; i++) {
      try {
        await transactions.add(newTransaction(account.id, name: 'x' * 200));
      } catch (e) {
        failure = e;
      }
    }

    expect(failure, isA<LocalWriteFailedException>());
    final cause = (failure as LocalWriteFailedException).cause;
    expect(cause, isA<SqliteException>());
    expect((cause as SqliteException).resultCode, 13, reason: 'SQLITE_FULL');
  });

  test('input errors and the typed exceptions are not turned into write failures', () async {
    await expectLater(accounts.add(AccountModel(0, '  ', 0, true, AccountType.Cash, 1, 0, false, false)),
        throwsArgumentError);
    await expectLater(transactions.add(newTransaction(account.id)..amount = 0), throwsArgumentError);
    await expectLater(
        categories.add(CategoryModel(0, 0, 'pets', 'x', true, true, '#ffffff')),
        throwsA(isA<CategoryNameTakenException>()));
  });

  test('a constraint violation is a bug and is not shown as "not saved"', () async {
    // Currency 99 doesn't exist, so the foreign key rejects the row.
    await expectLater(
        accounts.add(AccountModel(0, 'Main', 0, true, AccountType.Cash, 99, 0, false, false)),
        throwsA(isA<SqliteException>()));
  });

  test('category names differing only by accents or case are the same name', () async {
    await categories.add(CategoryModel(0, 0, 'Útiles', 'x', true, true, '#ffffff'));

    for (final name in ['útiles', 'ÚTILES', '  Útiles  ', 'Útiles']) {
      await expectLater(
          categories.add(CategoryModel(0, 0, name, 'x', true, true, '#ffffff')),
          throwsA(isA<CategoryNameTakenException>()),
          reason: name);
    }
    final other = await categories.add(CategoryModel(0, 0, 'Libros', 'x', true, true, '#ffffff'));
    other.name = 'úTILES';
    await expectLater(categories.update(other), throwsA(isA<CategoryNameTakenException>()));
  });

  test('a double submit of an accented category name saves it once', () async {
    final results = await Future.wait([
      for (var i = 0; i < 2; i++)
        categories
            .add(CategoryModel(0, 0, 'Útiles', 'x', true, true, '#ffffff'))
            .then((_) => 'saved', onError: (e) => e.runtimeType.toString()),
    ]);

    expect(results..sort(), ['CategoryNameTakenException', 'saved']);
  });

  test('a double submit of the same category name saves it once and reports the second as taken', () async {
    final results = await Future.wait([
      categories
          .add(CategoryModel(0, 0, 'Books', 'x', true, true, '#ffffff'))
          .then((_) => 'saved', onError: (e) => e.runtimeType.toString()),
      categories
          .add(CategoryModel(0, 0, 'Books', 'x', true, true, '#ffffff'))
          .then((_) => 'saved', onError: (e) => e.runtimeType.toString()),
    ]);

    expect(results..sort(), ['CategoryNameTakenException', 'saved']);
  });

  test('a failure from the background isolate the app uses is unwrapped too', () async {
    // The app opens its database with `driftDatabase`, which runs it in a
    // background isolate. There a SqliteException arrives wrapped in a
    // DriftRemoteException, which a plain `on SqliteException` would miss.
    final dir = Directory.systemTemp.createTempSync('write_failure');
    addTearDown(() => dir.deleteSync(recursive: true));
    await db.close();
    await setUpData(LocalDatabase(NativeDatabase.createInBackground(File('${dir.path}/local.sqlite'))));
    await makeStorageReadOnly(db);

    await expectLater(accounts.add(newAccount()), throwsWriteFailed);
  });
}
