import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/caching.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

/// Wires the app the way `main` does, so the mode-flip listener is the real one.
void main() {
  late AppModeService appMode;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late CurrencyRepository currencies;
  late TransactionRepository transactions;
  late Caching caching;
  late List<LocalDatabase> opened;
  late Directory directory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    opened = [];
    // A real file, so that what leaving local mode closes can be opened again.
    directory = Directory.systemTemp.createTempSync('mode_switch_');
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async {
      final db = LocalDatabase(NativeDatabase(File('${directory.path}/local.sqlite')));
      opened.add(db);
      return db;
    });
    await appMode.init();
    registerDependencies(PlatformStrategy.createPlatform(), appModeService: appMode);
    accounts = GetIt.I<AccountRepository>();
    categories = GetIt.I<CategoryRepository>();
    currencies = GetIt.I<CurrencyRepository>();
    transactions = GetIt.I<TransactionRepository>();
    caching = GetIt.I<Caching>();

    await appMode.enterLocalMode();
  });

  tearDown(() async {
    for (final db in opened) {
      try {
        await db.close();
      } catch (_) {}
    }
    await GetIt.I.reset();
    directory.deleteSync(recursive: true);
  });

  /// Loads the repositories the way the local home does, and opens an account's transactions.
  Future<void> useLocalData() async {
    await accounts.load();
    await currencies.load();
    await categories.load();
    await accounts.add(AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false));
    final account = accounts.getAllAccounts().single;
    await transactions.loadFirstPage(account.id);
    await transactions.add(
        TransactionModel(0, account.id, 1, 'Pay', 10, DateTime(2026, 1, 1), TransactionType.Income));
    caching.add('somethingFetched', 'value');
  }

  test('what one mode loaded is forgotten when the mode flips', () async {
    await useLocalData();
    expect(accounts.getAllAccounts(), isNotEmpty);
    expect(transactions.accountsContainer, isNotEmpty);

    await appMode.leaveLocalMode();

    expect(accounts.getAllAccounts(), isEmpty);
    expect(accounts.accounts, isEmpty);
    expect(categories.categories, isEmpty);
    expect(currencies.currencies, isEmpty);
    expect(transactions.accountsContainer, isEmpty, reason: 'ids repeat across modes');
    expect(transactions.transactions, isEmpty);
    expect(caching.store, isEmpty);
  });

  test('nothing is loaded again on its own: online that would fail before sign-in', () async {
    await useLocalData();

    await appMode.leaveLocalMode();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(accounts.getAllAccounts(), isEmpty);
    expect(categories.categories, isEmpty);
  });

  test('entering local mode again starts from an empty memory too', () async {
    await useLocalData();
    await appMode.leaveLocalMode();

    await appMode.enterLocalMode();

    expect(accounts.getAllAccounts(), isEmpty);
    expect(transactions.accountsContainer, isEmpty);
  });

  test('a change that is not a flip keeps what is loaded', () async {
    await useLocalData();
    final db = appMode.database!;
    await db.update(db.importStates).write(ImportStatesCompanion(status: Value(ImportStatus.inProgress)));

    await appMode.refreshImportStatus();

    expect(accounts.getAllAccounts(), hasLength(1));
    expect(transactions.accountsContainer, isNotEmpty);
    expect(caching.exists('somethingFetched'), isTrue);
  });

  test('local, then online, then local again: the data comes back from the file, '
      'and nothing carried over in memory', () async {
    await useLocalData();
    final before = accounts.getAllAccounts().single;
    final balance = before.balance;
    expect(balance, 10);

    await appMode.leaveLocalMode();
    expect(appMode.isLocal, isFalse);
    expect(accounts.getAllAccounts(), isEmpty, reason: 'online starts from nothing');
    expect(caching.exists('somethingFetched'), isFalse);

    await appMode.enterLocalMode();
    expect(accounts.getAllAccounts(), isEmpty, reason: 'memory is empty until a screen loads');
    await accounts.load();
    await currencies.load();
    await categories.load();

    final back = accounts.getAllAccounts().single;
    expect(back.name, before.name);
    expect(back.balance, balance);
    expect(identical(back, before), isFalse, reason: 'a new object, read from the file');
    await transactions.loadFirstPage(back.id);
    expect(transactions.transactions.map((t) => t.name), ['Pay']);
    expect(categories.categories, hasLength(17));
    expect(caching.exists('somethingFetched'), isFalse);
  });

  test('a second round trip changes nothing, and what was added in between is kept', () async {
    await useLocalData();
    await appMode.leaveLocalMode();
    await appMode.enterLocalMode();
    await accounts.load();
    await currencies.load();
    await categories.load();
    final account = accounts.getAllAccounts().single;
    await transactions.loadFirstPage(account.id);
    await transactions.add(TransactionModel(
        0, account.id, 1, 'Coffee', 4, DateTime(2026, 2, 1), TransactionType.Outcome));
    expect(accounts.getAllAccounts().single.balance, 6);

    await appMode.leaveLocalMode();
    await appMode.enterLocalMode();
    await accounts.load();

    expect(accounts.getAllAccounts().single.balance, 6);
    await transactions.loadFirstPage(accounts.getAllAccounts().single.id);
    expect(transactions.transactions.map((t) => t.name).toSet(), {'Pay', 'Coffee'});
  });
}
