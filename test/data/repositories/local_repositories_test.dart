import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

/// Stand in for the server. Local mode must never reach them.
class _UnreachableAccounts implements AccountDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Local mode reached the server: ${invocation.memberName}');
}

class _UnreachableTransactions implements TransactionDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Local mode reached the server: ${invocation.memberName}');
}

/// `TransactionRepository` keeps the concrete service for server-only calls (tags, previews).
class _UnreachableTransactionService implements TransactionService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Local mode reached the server: ${invocation.memberName}');
}

void main() {
  late AppModeService appMode;
  late LocalDatabase database;
  late AccountRepository accounts;
  late TransactionRepository transactions;
  late List<AccountModel> created;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();
    database = appMode.database!;

    final notifier = NotifierService();
    accounts = AccountRepository(
        accountService: ModeAwareAccountDataSource(_UnreachableAccounts(), appMode),
        notifierService: notifier);
    transactions = TransactionRepository(
        transactionService: _UnreachableTransactionService(),
        dataSource: ModeAwareTransactionDataSource(_UnreachableTransactions(), appMode),
        accountRepository: accounts,
        errorNotifierService: notifier);

    created = [];
    for (var i = 0; i < 5; i++) {
      await accounts.add(AccountModel(
          0, 'Account $i', 0, true, AccountType.Cash, 1, 0, false, false));
    }
    created = accounts.getAllAccounts();
  });

  tearDown(() => database.close());

  TransactionModel newTransaction(AccountModel account, double amount,
          TransactionType type, {int day = 1}) =>
      TransactionModel(0, account.id, 1, 'Item', amount, DateTime(2026, 1, day), type);

  /// What the repository shows must equal what the database derives (FR-008).
  Future<void> expectBalancesMatchDatabase() async {
    final fresh = await ModeAwareAccountDataSource(_UnreachableAccounts(), appMode)
        .fetchAccounts();
    expect(fresh, hasLength(5));
    for (final account in fresh) {
      final shown = accounts.getAllAccounts().firstWhere((a) => a.id == account.id);
      expect(shown.balance, closeTo(account.balance, 0.001),
          reason: 'account ${account.id}');
    }
  }

  test('adding a transaction updates the account balance from the result', () async {
    final account = created.first;
    await transactions.loadFirstPage(account.id);

    await transactions.add(newTransaction(account, 100, TransactionType.Income));
    expect(accounts.getAllAccounts().first.balance, closeTo(100, 0.001));
    await transactions.add(newTransaction(account, 30, TransactionType.Outcome));
    expect(accounts.getAllAccounts().first.balance, closeTo(70, 0.001));

    await expectBalancesMatchDatabase();
  });

  test('editing and removing keep the shown balance equal to the database', () async {
    final account = created.first;
    await transactions.loadFirstPage(account.id);
    await transactions.add(newTransaction(account, 100, TransactionType.Income));
    await transactions.add(newTransaction(account, 30, TransactionType.Outcome));
    await transactions.loadFirstPage(account.id);
    final outcome = transactions.transactions.firstWhere((t) => !t.isIncome());
    final income = transactions.transactions.firstWhere((t) => t.isIncome());

    await transactions.update(outcome.clone()..amount = 40);
    expect(accounts.getAllAccounts().first.balance, closeTo(60, 0.001));
    await expectBalancesMatchDatabase();

    await transactions.remove(income);
    expect(accounts.getAllAccounts().first.balance, closeTo(-40, 0.001));
    await expectBalancesMatchDatabase();
  });

  test('deleting an account that has transactions is refused with a typed error', () async {
    final account = created.first;
    await transactions.loadFirstPage(account.id);
    await transactions.add(newTransaction(account, 10, TransactionType.Outcome));

    await expectLater(accounts.delete(account),
        throwsA(isA<AccountHasTransactionsException>()));

    expect(accounts.accounts, hasLength(5), reason: 'the account stays');
    await accounts.delete(created.last);
    expect(accounts.accounts, hasLength(4), reason: 'an empty one can go');
    expect(await ModeAwareAccountDataSource(_UnreachableAccounts(), appMode).fetchAccounts(),
        hasLength(4));
  });

  /// The sum of each account's rows, worked out here from the raw table: neither the
  /// repository's running balance nor the query the data source uses for it.
  Future<Map<int, double>> rawSums() async {
    final sums = <int, double>{for (final a in created) a.id: 0};
    for (final row in await database.select(database.transactions).get()) {
      sums[row.accountId] = sums[row.accountId]! +
          (row.transactionType == 0 ? row.amount : -row.amount);
    }
    return sums;
  }

  Future<void> expectBalancesEqualRawSums() async {
    final sums = await rawSums();
    for (final account in accounts.getAllAccounts()) {
      expect(account.balance, closeTo(sums[account.id]!, 0.001),
          reason: 'account ${account.id}: what is shown is not the sum of its transactions');
    }
  }

  Future<int> rowCount() async =>
      (await database.select(database.transactions).get()).length;

  test('balances stay equal to the sum of the transactions across 1,000 of them in 5 accounts, '
      'through every kind of edit (SC-003, US2-3)', () async {
    final random = Random(20261018);
    double randomAmount() => (random.nextInt(50000) + 1) / 100;
    TransactionType randomType() =>
        random.nextBool() ? TransactionType.Income : TransactionType.Outcome;

    // The dataset first: 1,000 transactions, spread over the 5 accounts and many days.
    for (var i = 0; i < 1000; i++) {
      final account = created[i % created.length];
      await transactions.loadFirstPage(account.id);
      await transactions.add(newTransaction(account, randomAmount(), randomType(),
          day: 1 + random.nextInt(28)));
    }
    expect(await rowCount(), 1000);
    await expectBalancesMatchDatabase();
    await expectBalancesEqualRawSums();

    // Then edits of every kind, on what an account's page shows, as in the UI.
    final done = <String, int>{};
    void count(String what) => done[what] = (done[what] ?? 0) + 1;

    for (var operation = 0; operation < 600; operation++) {
      final account = created[random.nextInt(created.length)];
      await transactions.loadFirstPage(account.id);
      final visible = transactions.transactions;
      final roll = random.nextInt(100);

      if (roll < 25 || visible.isEmpty) {
        await transactions.add(newTransaction(account, randomAmount(), randomType(),
            day: 1 + random.nextInt(28)));
        count('add');
      } else if (roll < 45) {
        await transactions.update(visible[random.nextInt(visible.length)].clone()
          ..amount = randomAmount());
        count('amount');
      } else if (roll < 60) {
        await transactions.update(visible[random.nextInt(visible.length)].clone()
          ..transactionType = randomType());
        count('type');
      } else if (roll < 75) {
        await transactions.update(visible[random.nextInt(visible.length)].clone()
          ..date = DateTime(2026, 1, 1 + random.nextInt(28)));
        count('date');
      } else if (roll < 88) {
        final others = created.where((a) => a.id != account.id).toList();
        await transactions.update(visible[random.nextInt(visible.length)].clone()
          ..accountId = others[random.nextInt(others.length)].id);
        count('account');
      } else {
        await transactions.remove(visible[random.nextInt(visible.length)]);
        count('delete');
      }

      await expectBalancesMatchDatabase();
      if (operation % 25 == 0) await expectBalancesEqualRawSums();
    }
    await expectBalancesEqualRawSums();

    for (final kind in ['add', 'amount', 'type', 'date', 'account', 'delete']) {
      expect(done[kind] ?? 0, greaterThan(40), reason: 'only ${done[kind]} "$kind" operations ran');
    }
    expect(await rowCount(), greaterThanOrEqualTo(1000),
        reason: 'the dataset stayed at the size SC-003 asks for');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
