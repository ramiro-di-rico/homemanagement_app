import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_account.service.dart';
import 'package:home_management_app/data/local/local_category.service.dart';
import 'package:home_management_app/data/local/local_currency.service.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_transaction.service.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

void main() {
  late LocalDatabase db;
  late LocalAccountService accounts;
  late LocalCategoryService categories;
  late LocalTransactionService transactions;
  late AccountModel account;

  setUp(() async {
    db = LocalDatabase(NativeDatabase.memory());
    accounts = LocalAccountService(db);
    categories = LocalCategoryService(db);
    transactions = LocalTransactionService(db);
    account = await accounts.add(
        AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false));
  });
  tearDown(() => db.close());

  TransactionModel tx(double amount, TransactionType type,
          {String name = 'Item', DateTime? date, int categoryId = 1, int? accountId}) =>
      TransactionModel(0, accountId ?? account.id, categoryId, name, amount,
          date ?? DateTime(2026, 1, 1), type);

  Future<double> balance() async =>
      (await accounts.fetchAccounts()).firstWhere((a) => a.id == account.id).balance;

  group('currencies', () {
    test('returns the seeded rows', () async {
      final result = await LocalCurrencyService(db).fetchCurrencies();
      expect(result.map((c) => c.name), ['USD', 'ARS', 'EUR']);
    });
  });

  group('accounts', () {
    test('add returns the created account with its id and a zero balance', () {
      expect(account.id, greaterThan(0));
      expect(account.balance, 0);
      expect(account.userId, 0);
    });

    test('add trims the name and rejects an empty or too long one', () async {
      final padded = await accounts.add(AccountModel(
          0, '  Savings  ', 0, true, AccountType.BankAccount, 2, 0, false, false));
      expect(padded.name, 'Savings');
      expect(padded.accountType, AccountType.BankAccount);
      await expectLater(
          accounts.add(AccountModel(0, '   ', 0, true, AccountType.Cash, 1, 0, false, false)),
          throwsArgumentError);
      await expectLater(
          accounts.add(AccountModel(0, 'x' * 101, 0, true, AccountType.Cash, 1, 0, false, false)),
          throwsArgumentError);
    });

    test('update covers rename, hide and archive', () async {
      account.name = 'Renamed';
      account.isHidden = true;
      account.archive = true;
      await accounts.update(account);
      final saved = (await accounts.fetchAccounts()).single;
      expect(saved.name, 'Renamed');
      expect(saved.isHidden, isTrue);
      expect(saved.archive, isTrue);
    });

    test('delete works when empty and is blocked when it has transactions', () async {
      await transactions.add(tx(5, TransactionType.Income));
      await expectLater(accounts.delete(account), throwsA(isA<AccountHasTransactionsException>()));
      expect(await accounts.fetchAccounts(), hasLength(1));

      final empty = await accounts.add(
          AccountModel(0, 'Empty', 0, true, AccountType.Cash, 1, 0, false, false));
      await accounts.delete(empty);
      expect(await accounts.fetchAccounts(), hasLength(1));
    });
  });

  group('balances (quickstart Q4)', () {
    test('follow add, edit and delete of income and outcome', () async {
      final income = (await transactions.add(tx(100, TransactionType.Income))).transactionModel;
      final outcome = (await transactions.add(tx(30, TransactionType.Outcome))).transactionModel;
      expect(await balance(), closeTo(70, 0.001));

      outcome.amount = 40;
      await transactions.update(outcome);
      expect(await balance(), closeTo(60, 0.001));

      await transactions.delete(income.id);
      expect(await balance(), closeTo(-40, 0.001));
    });

    test('add returns the source account with its post-insert balance', () async {
      await transactions.add(tx(100, TransactionType.Income));
      final result = await transactions.add(tx(30, TransactionType.Outcome));
      expect(result.sourceAccount.id, account.id);
      expect(result.sourceAccount.balance, closeTo(70, 0.001));
      expect(result.targetAccount, isNull);
      expect(result.transactionModel.id, greaterThan(0));
      expect(result.transactionModel.categoryName, 'Various');
    });

    test('add rejects a non-positive amount and an empty name', () async {
      await expectLater(transactions.add(tx(0, TransactionType.Income)), throwsArgumentError);
      await expectLater(transactions.add(tx(-1, TransactionType.Income)), throwsArgumentError);
      await expectLater(
          transactions.add(tx(1, TransactionType.Income, name: '  ')), throwsArgumentError);
    });
  });

  group('transactions', () {
    test('the date is kept as the chosen calendar day', () async {
      final added = await transactions
          .add(tx(1, TransactionType.Income, date: DateTime(2026, 3, 15, 23, 30)));
      final read = (await transactions.page(TransactionPageModel.newPage(account.id, 1, 10))).single;
      expect(added.transactionModel.date, DateTime(2026, 3, 15));
      expect(read.date, DateTime(2026, 3, 15));
    });

    test('paging is most recent first with the given page size', () async {
      for (var day = 1; day <= 5; day++) {
        await transactions.add(tx(1, TransactionType.Income,
            name: 'Day $day', date: DateTime(2026, 1, day)));
      }
      // Same date as Day 5, inserted later: wins the tie by id.
      await transactions.add(tx(1, TransactionType.Income, name: 'Day 5 late', date: DateTime(2026, 1, 5)));

      final first = await transactions.page(TransactionPageModel.newPage(account.id, 1, 4));
      expect(first.map((t) => t.name), ['Day 5 late', 'Day 5', 'Day 4', 'Day 3']);
      final second = await transactions.page(TransactionPageModel.newPage(account.id, 2, 4));
      expect(second.map((t) => t.name), ['Day 2', 'Day 1']);
    });

    test('paging only returns the requested account', () async {
      final other = await accounts.add(
          AccountModel(0, 'Other', 0, true, AccountType.Cash, 1, 0, false, false));
      await transactions.add(tx(1, TransactionType.Income, name: 'Mine'));
      await transactions.add(tx(1, TransactionType.Income, name: 'Theirs', accountId: other.id));
      final result = await transactions.page(TransactionPageModel.newPage(account.id, 1, 10));
      expect(result.map((t) => t.name), ['Mine']);
    });

    test('name filtering ignores case and treats % literally', () async {
      await transactions.add(tx(1, TransactionType.Outcome, name: 'Coffee beans'));
      await transactions.add(tx(1, TransactionType.Outcome, name: 'Tea'));
      await transactions.add(tx(1, TransactionType.Outcome, name: '100% juice'));
      final page = TransactionPageModel.newPage(account.id, 1, 10);
      expect((await transactions.pageNameFiltering(page, 'COFFEE')).map((t) => t.name), ['Coffee beans']);
      expect((await transactions.pageNameFiltering(page, '%')).map((t) => t.name), ['100% juice']);
    });

    test('suggested returns distinct names, most recent first, at most 10', () async {
      for (var i = 0; i < 12; i++) {
        await transactions.add(tx(1, TransactionType.Outcome,
            name: 'Item $i', date: DateTime(2026, 1, 1 + i)));
      }
      await transactions.add(tx(1, TransactionType.Outcome,
          name: 'Item 0', date: DateTime(2026, 2, 1)));
      final result = await transactions.suggested();
      expect(result, hasLength(10));
      expect(result.map((t) => t.name).toSet(), hasLength(10));
      expect(result.first.name, 'Item 0');
    });
  });

  group('categories', () {
    test('fetch returns inactive categories too', () async {
      final created = await categories.add(CategoryModel(0, 0, 'Hidden', 'home', true, false, '#ffffff'));
      final all = await categories.fetch();
      expect(all, hasLength(18));
      expect(all.firstWhere((c) => c.id == created.id).isActive, isFalse);
    });

    test('add and update reject a name taken ignoring case', () async {
      await expectLater(
          categories.add(CategoryModel(0, 0, ' rent ', 'home', true, true, '#ffffff')),
          throwsA(isA<CategoryNameTakenException>()));

      final mine = await categories.add(CategoryModel(0, 0, 'Pets', 'pets', true, true, '#ffffff'));
      mine.name = 'GIFT';
      await expectLater(categories.update(mine), throwsA(isA<CategoryNameTakenException>()));
    });

    test('update may keep its own name and changes the other fields', () async {
      final mine = await categories.add(CategoryModel(0, 0, 'Pets', 'pets', true, true, '#ffffff'));
      final changed = CategoryModel(mine.id, 0, 'Pets', 'cat', false, false, '#123456');
      await categories.update(changed);
      final saved = (await categories.fetch()).firstWhere((c) => c.id == mine.id);
      expect((saved.icon, saved.measurable, saved.isActive, saved.color),
          ('cat', false, false, '#123456'));
    });

    test('delete works when unused and is blocked when a transaction uses it', () async {
      final unused = await categories.add(CategoryModel(0, 0, 'Pets', 'pets', true, true, '#ffffff'));
      await categories.delete(unused);
      expect(await categories.fetch(), hasLength(17));

      await transactions.add(tx(1, TransactionType.Income, categoryId: 1));
      final used = (await categories.fetch()).firstWhere((c) => c.id == 1);
      await expectLater(categories.delete(used), throwsA(isA<CategoryInUseException>()));
      expect(await categories.fetch(), hasLength(17));
    });
  });
}
