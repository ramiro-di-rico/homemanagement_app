import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/models/transaction-with-balance.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/sources/local_data_locked_exception.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

class FakeRemoteAccounts implements AccountDataSource {
  final List<String> calls = [];

  @override
  Future<List<AccountModel>> fetchAccounts() async {
    calls.add('fetchAccounts');
    return [AccountModel(77, 'Remote', 5, true, AccountType.Cash, 1, 1, false, false)];
  }

  @override
  Future<AccountModel> add(AccountModel account) async {
    calls.add('add');
    return account;
  }

  @override
  Future update(AccountModel account) async => calls.add('update');

  @override
  Future delete(AccountModel account) async => calls.add('delete');
}

class FakeRemoteCategories implements CategoryDataSource {
  final List<String> calls = [];

  @override
  Future<List<CategoryModel>> fetch() async {
    calls.add('fetch');
    return [CategoryModel(9, 1, 'Remote category', 'home', true, true, '#ffffff')];
  }

  @override
  Future<CategoryModel> add(CategoryModel category) async => category;

  @override
  Future update(CategoryModel category) async {}

  @override
  Future delete(CategoryModel category) async {}
}

class FakeRemoteCurrencies implements CurrencyDataSource {
  final List<String> calls = [];

  @override
  Future<List<CurrencyModel>> fetchCurrencies() async {
    calls.add('fetchCurrencies');
    return [CurrencyModel(50, 'REMOTE', 1)];
  }
}

class FakeRemoteTransactions implements TransactionDataSource {
  final List<String> calls = [];

  @override
  Future<List<TransactionModel>> page(TransactionPageModel page) async {
    calls.add('page');
    return [];
  }

  @override
  Future<List<TransactionModel>> pageNameFiltering(TransactionPageModel page, String name) async => [];

  @override
  Future<List<TransactionModel>> suggested() async => [];

  @override
  Future<TransactionWithBalanceModel> add(TransactionModel transaction) async {
    calls.add('add');
    return TransactionWithBalanceModel(transaction,
        AccountModel(transaction.accountId, 'Remote', 0, true, AccountType.Cash, 1, 1, false, false), null);
  }

  @override
  Future update(TransactionModel transaction) async {}

  @override
  Future delete(int id) async {}
}

void main() {
  late List<LocalDatabase> opened;

  AppModeService createService({PlatformType platform = PlatformType.Desktop, LocalDatabaseOpener? opener}) =>
      AppModeService(FakePlatform(platform),
          openDatabase: opener ??
              (_, {required mustExist}) async {
                final db = LocalDatabase(NativeDatabase.memory());
                opened.add(db);
                return db;
              });

  setUp(() {
    opened = [];
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    for (final db in opened) {
      await db.close();
    }
  });

  group('routing', () {
    test('calls go to the remote when online and to the local database when local, without recreating the delegates', () async {
      final appMode = createService();
      await appMode.init();
      final remoteAccounts = FakeRemoteAccounts();
      final remoteCategories = FakeRemoteCategories();
      final remoteCurrencies = FakeRemoteCurrencies();
      final remoteTransactions = FakeRemoteTransactions();
      final accounts = ModeAwareAccountDataSource(remoteAccounts, appMode);
      final categories = ModeAwareCategoryDataSource(remoteCategories, appMode);
      final currencies = ModeAwareCurrencyDataSource(remoteCurrencies, appMode);
      final transactions = ModeAwareTransactionDataSource(remoteTransactions, appMode);

      expect((await accounts.fetchAccounts()).single.name, 'Remote');
      expect((await categories.fetch()).single.name, 'Remote category');
      expect((await currencies.fetchCurrencies()).single.name, 'REMOTE');
      await transactions.page(TransactionPageModel.newPage(1, 1, 10));
      expect(remoteAccounts.calls, ['fetchAccounts']);

      await appMode.enterLocalMode();

      expect(await accounts.fetchAccounts(), isEmpty);
      expect(await categories.fetch(), hasLength(17));
      expect((await currencies.fetchCurrencies()).map((c) => c.name), ['USD', 'ARS', 'EUR']);
      final created = await accounts.add(AccountModel(0, 'Local', 0, true, AccountType.Cash, 1, 0, false, false));
      expect(created.id, 1);
      expect(remoteAccounts.calls, ['fetchAccounts'], reason: 'nothing more reached the remote');
      expect(remoteTransactions.calls, ['page']);
    });

    test('a local write is visible through the same delegate afterwards', () async {
      final appMode = createService();
      await appMode.init();
      await appMode.enterLocalMode();
      final accounts = ModeAwareAccountDataSource(FakeRemoteAccounts(), appMode);
      final transactions = ModeAwareTransactionDataSource(FakeRemoteTransactions(), appMode);

      final account = await accounts.add(AccountModel(0, 'Local', 0, true, AccountType.Cash, 1, 0, false, false));
      final result = await transactions.add(
          TransactionModel(0, account.id, 1, 'Pay', 100, DateTime(2026, 1, 1), TransactionType.Income));

      expect(result.sourceAccount.balance, closeTo(100, 0.001));
      expect((await accounts.fetchAccounts()).single.balance, closeTo(100, 0.001));
    });
  });

  group('AppModeService', () {
    test('starts online and local mode is only available on desktop', () async {
      final desktop = createService();
      await desktop.init();
      expect(desktop.isLocal, isFalse);
      expect(desktop.isLocalAvailable, isTrue);

      for (final type in [PlatformType.Web, PlatformType.WebMobile, PlatformType.Mobile]) {
        final other = createService(platform: type);
        expect(other.isLocalAvailable, isFalse, reason: type.name);
        await expectLater(other.enterLocalMode(), throwsStateError);
      }
    });

    test('entering local mode persists it and notifies', () async {
      final appMode = createService();
      await appMode.init();
      var notified = 0;
      appMode.addListener(() => notified++);

      await appMode.enterLocalMode();

      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNotNull);
      expect(notified, 1);
      expect((await SharedPreferences.getInstance()).getString('appMode'), 'local');
    });

    test('a later start reopens the local data', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final appMode = createService();
      await appMode.init();
      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNotNull);
      expect(appMode.startupError, isNull);
    });

    test('a stored local mode is ignored where local mode is unavailable', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final appMode = createService(platform: PlatformType.Web);
      await appMode.init();
      expect(appMode.isLocal, isFalse);
      expect(appMode.database, isNull);
    });

    test('data that cannot be opened is reported, stays local, and Retry can succeed', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      var fail = true;
      final appMode = createService(opener: (_, {required mustExist}) async {
        if (fail) {
          throw LocalDataUnavailableException(LocalDataUnavailableReason.keyringUnavailable);
        }
        final db = LocalDatabase(NativeDatabase.memory());
        opened.add(db);
        return db;
      });

      await appMode.init();
      expect(appMode.startupError?.reason, LocalDataUnavailableReason.keyringUnavailable);
      expect(appMode.isLocal, isTrue, reason: 'must not fall back to online');
      expect(appMode.database, isNull);

      fail = false;
      await appMode.init();
      expect(appMode.startupError, isNull);
      expect(appMode.database, isNotNull);
    });

    test('entering local mode while the data cannot be opened leaves the mode unchanged', () async {
      final appMode = createService(
          opener: (_, {required mustExist}) async => throw LocalDataUnavailableException(LocalDataUnavailableReason.keyringUnavailable));
      await appMode.init();

      await expectLater(appMode.enterLocalMode(), throwsA(isA<LocalDataUnavailableException>()));

      expect(appMode.isLocal, isFalse);
      expect((await SharedPreferences.getInstance()).getString('appMode'), isNull);
    });

    test('calls made while local mode is being entered share one opening', () async {
      var opens = 0;
      final appMode = createService(opener: (_, {required mustExist}) async {
        opens++;
        await Future.delayed(const Duration(milliseconds: 20));
        final db = LocalDatabase(NativeDatabase.memory());
        opened.add(db);
        return db;
      });
      await appMode.init();

      await Future.wait([appMode.enterLocalMode(), appMode.enterLocalMode(), appMode.enterLocalMode()]);

      expect(opens, 1);
      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNotNull);
    });

    test('a failed entry does not block the next one', () async {
      var fail = true;
      final appMode = createService(opener: (_, {required mustExist}) async {
        if (fail) throw LocalDataUnavailableException(LocalDataUnavailableReason.keyringUnavailable);
        final db = LocalDatabase(NativeDatabase.memory());
        opened.add(db);
        return db;
      });
      await appMode.init();
      await expectLater(appMode.enterLocalMode(), throwsA(isA<LocalDataUnavailableException>()));

      fail = false;
      await appMode.enterLocalMode();

      expect(appMode.isLocal, isTrue);
    });

    test('the file must exist when the user was already in local mode, not on the first entry', () async {
      final asked = <bool>[];
      Future<LocalDatabase> opener(String _, {required bool mustExist}) async {
        asked.add(mustExist);
        final db = LocalDatabase(NativeDatabase.memory());
        opened.add(db);
        return db;
      }

      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final returning = createService(opener: opener);
      await returning.init();
      SharedPreferences.setMockInitialValues({});
      final first = createService(opener: opener);
      await first.init();
      await first.enterLocalMode();

      expect(asked, [true, false]);
    });

    test('a missing file is reported and nothing is created', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final appMode = createService(
          opener: (_, {required mustExist}) async => throw LocalDataUnavailableException(
              LocalDataUnavailableReason.fileMissing));

      await appMode.init();

      expect(appMode.startupError?.reason, LocalDataUnavailableReason.fileMissing);
      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNull);
    });

    test('an unexpected error while opening is reported, not thrown', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final appMode = createService(
          opener: (_, {required mustExist}) async => throw StateError('disk exploded'));

      await appMode.init();

      expect(appMode.startupError?.reason, LocalDataUnavailableReason.unreadable);
      expect(appMode.startupError?.cause, isA<StateError>());
    });

    test('a broken preferences file still lets the app start, online', () async {
      final appMode = AppModeService(FakePlatform(PlatformType.Desktop),
          loadPreferences: () async => throw const FormatException('broken json'));

      await appMode.init();

      expect(appMode.isLocal, isFalse);
      expect(appMode.startupError, isNull);
    });

    test('leaving local mode keeps the data and the way back', () async {
      final appMode = createService();
      await appMode.init();
      await appMode.enterLocalMode();
      final database = appMode.database!;
      await database.into(database.accounts).insert(
          AccountsCompanion.insert(name: 'Kept', accountType: 0, currencyId: 1));

      await appMode.leaveLocalMode();

      expect(appMode.isLocal, isFalse);
      expect(appMode.database, isNull);
      expect(appMode.startupError, isNull);
      expect((await SharedPreferences.getInstance()).getString('appMode'), 'online');
    });

    test('after leaving, calls go to the remote, and entering again finds the earlier local data', () async {
      // A real file, so that closing and reopening it keeps the rows.
      final dir = Directory.systemTemp.createTempSync('leave_and_return');
      addTearDown(() => dir.deleteSync(recursive: true));
      final appMode = createService(opener: (_, {required mustExist}) async {
        final db = LocalDatabase(NativeDatabase(File('${dir.path}/local.sqlite')));
        opened.add(db);
        return db;
      });
      await appMode.init();
      await appMode.enterLocalMode();
      final remote = FakeRemoteAccounts();
      final accounts = ModeAwareAccountDataSource(remote, appMode);
      await accounts.add(AccountModel(0, 'Kept', 0, true, AccountType.Cash, 1, 0, false, false));
      expect(remote.calls, isEmpty);

      await appMode.leaveLocalMode();
      expect((await accounts.fetchAccounts()).single.name, 'Remote');
      expect(remote.calls, ['fetchAccounts']);

      await appMode.enterLocalMode();
      expect((await accounts.fetchAccounts()).map((a) => a.name), ['Kept']);
      expect(remote.calls, ['fetchAccounts'], reason: 'local again, so nothing more went to the server');
    });

    test('leaving local mode is also the way out of an unreadable file', () async {
      SharedPreferences.setMockInitialValues({'appMode': 'local'});
      final appMode = createService(
          opener: (_, {required mustExist}) async =>
              throw LocalDataUnavailableException(LocalDataUnavailableReason.keyMissing));
      await appMode.init();
      expect(appMode.startupError, isNotNull);

      await appMode.leaveLocalMode();

      expect(appMode.isLocal, isFalse);
      expect(appMode.startupError, isNull);
    });

    test('leaving local mode is refused while an import is pending', () async {
      final appMode = createService();
      await appMode.init();
      await appMode.enterLocalMode();
      final db = appMode.database!;
      await db.update(db.importStates).write(ImportStatesCompanion(status: Value(ImportStatus.inProgress)));
      await appMode.refreshImportStatus();

      await expectLater(appMode.leaveLocalMode(), throwsStateError);
      expect(appMode.isLocal, isTrue);
    });

    test('isImportPending follows import_states.status', () async {
      final appMode = createService();
      await appMode.init();
      await appMode.enterLocalMode();
      expect(appMode.isImportPending, isFalse);

      final db = appMode.database!;
      for (final (status, pending) in [
        (ImportStatus.inProgress, true),
        (ImportStatus.failed, true),
        (ImportStatus.notStarted, false),
      ]) {
        await db.update(db.importStates).write(ImportStatesCompanion(status: Value(status)));
        await appMode.refreshImportStatus();
        expect(appMode.isImportPending, pending, reason: status.name);
      }
    });
  });

  group('write lock while an import is pending (FR-022)', () {
    late AppModeService appMode;
    late FakeRemoteAccounts remote;
    late ModeAwareAccountDataSource accounts;
    late ModeAwareCategoryDataSource categories;
    late ModeAwareTransactionDataSource transactions;

    setUp(() async {
      appMode = createService();
      await appMode.init();
      await appMode.enterLocalMode();
      remote = FakeRemoteAccounts();
      accounts = ModeAwareAccountDataSource(remote, appMode);
      categories = ModeAwareCategoryDataSource(FakeRemoteCategories(), appMode);
      transactions =
          ModeAwareTransactionDataSource(FakeRemoteTransactions(), appMode);
    });

    Future<void> setStatus(ImportStatus status) async {
      final db = appMode.database!;
      await (db.update(db.importStates)..where((s) => s.id.equals(1)))
          .write(ImportStatesCompanion(status: Value(status)));
      await appMode.refreshImportStatus();
    }

    final account =
        AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false);

    test('writes are allowed while the import has not started', () async {
      final created = await accounts.add(account);

      expect(created.id, greaterThan(0));
    });

    for (final status in [
      ImportStatus.inProgress,
      ImportStatus.failed,
      ImportStatus.completed,
    ]) {
      test('every write is rejected while the status is ${status.name}, '
          'and nothing reaches the database or the server', () async {
        final created = await accounts.add(account);
        final category = (await categories.fetch()).first;
        final transaction = TransactionModel(
            0, created.id, category.id, 'Pay', 5, DateTime(2026, 1, 1), TransactionType.Income);
        await setStatus(status);

        for (final write in <Future Function()>[
          () => accounts.add(account),
          () => accounts.update(created),
          () => accounts.delete(created),
          () => categories.add(CategoryModel(0, 0, 'New', 'home', true, true, '#ffffff')),
          () => categories.update(category),
          () => categories.delete(category),
          () => transactions.add(transaction),
          () => transactions.update(transaction),
          () => transactions.delete(1),
        ]) {
          await expectLater(write(), throwsA(isA<LocalDataLockedException>()));
        }

        expect((await accounts.fetchAccounts()).map((a) => a.name), ['Main']);
        expect(remote.calls, isEmpty);
      });
    }

    test('reads still work while locked', () async {
      await accounts.add(account);
      await setStatus(ImportStatus.inProgress);

      expect(await accounts.fetchAccounts(), hasLength(1));
      expect(await categories.fetch(), isNotEmpty);
      expect(await transactions.suggested(), isEmpty);
    });

    test('online, writes go to the server as before', () async {
      // The group's setUp saved "local", so start from clean preferences.
      SharedPreferences.setMockInitialValues({});
      final online = createService();
      await online.init();
      final onlineRemote = FakeRemoteAccounts();

      await ModeAwareAccountDataSource(onlineRemote, online).add(account);

      expect(onlineRemote.calls, ['add']);
    });

    test('leaving local mode is refused while locked, so the lock can\'t be dodged',
        () async {
      await setStatus(ImportStatus.failed);

      await expectLater(appMode.leaveLocalMode(), throwsStateError);

      expect(appMode.isLocal, isTrue);
    });

    test('a locked rejection is a "not saved" failure too', () {
      expect(LocalDataLockedException(), isA<LocalWriteFailedException>());
    });
  });
}
