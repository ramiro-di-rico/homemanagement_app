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
        openDatabase: (_) async => LocalDatabase(NativeDatabase.memory()));
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

  test('1,000 random operations across 5 accounts never let the balances drift', () async {
    final random = Random(20261018);
    var operations = 0;
    var adds = 0, updates = 0, removes = 0;

    while (operations < 1000) {
      final account = created[random.nextInt(created.length)];
      await transactions.loadFirstPage(account.id);
      // Only what the account's page shows can be edited or removed, as in the UI.
      final visible = transactions.transactions;
      final roll = random.nextInt(100);
      final amount = (random.nextInt(50000) + 1) / 100;
      final type = random.nextBool() ? TransactionType.Income : TransactionType.Outcome;

      if (roll < 50 || visible.isEmpty) {
        await transactions.add(newTransaction(account, amount, type,
            day: 1 + random.nextInt(28)));
        adds++;
      } else if (roll < 75) {
        final target = visible[random.nextInt(visible.length)].clone()
          ..amount = amount
          ..transactionType = type;
        await transactions.update(target);
        updates++;
      } else {
        await transactions.remove(visible[random.nextInt(visible.length)]);
        removes++;
      }
      operations++;
      await expectBalancesMatchDatabase();
    }

    expect(adds, greaterThan(300));
    expect(updates, greaterThan(100));
    expect(removes, greaterThan(100));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
