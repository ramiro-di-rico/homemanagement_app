import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/services/local_import.service.dart';
import 'package:home_management_app/data/services/sources/bulk_transaction_client.dart';
import 'package:home_management_app/data/services/sources/import_currency_missing_exception.dart';
import 'package:home_management_app/data/services/sources/import_wrong_user_exception.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/local_data_locked_exception.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

/// One in-memory "server" behind all four seams (the account one through
/// [_AccountsOf], because account and category `add`/`update` clash) the import talks to. It behaves
/// like the real backend where that matters for the import (research R4, R6):
/// creating an account or category ignores everything but the name, and a bulk
/// request is applied to balances as a whole.
class FakeServer
    implements CategoryDataSource, CurrencyDataSource, BulkTransactionClient {
  final List<CurrencyModel> currencyList = [
    CurrencyModel(10, 'USD', 1),
    CurrencyModel(20, 'ARS', 0),
  ];
  final List<CategoryModel> categoryList = [];
  final List<AccountModel> accountList = [
    AccountModel(1, 'Cash', 0, true, AccountType.Cash, 10, 1, false, false),
  ];

  int _nextId = 500;
  int writes = 0;
  final List<String> createdCategoryNames = [];

  /// Every bulk request: the transactions, and the names of ALL server accounts
  /// at the moment it was sent.
  final List<List<TransactionModel>> bulkRequests = [];
  final List<List<String>> accountNamesAtBulk = [];
  final Map<int, int> transactionCount = {};

  /// 1-based bulk call that is applied and then throws, like a lost response.
  int? failAfterApplyingBulkCall;

  /// Added to the balance of every bulk request, to force a mismatch.
  double balanceSkew = 0;

  AccountModel account(int id) => accountList.firstWhere((a) => a.id == id);

  @override
  Future<List<CurrencyModel>> fetchCurrencies() async => List.of(currencyList);

  @override
  Future<List<CategoryModel>> fetch() async => List.of(categoryList);

  @override
  Future<CategoryModel> add(CategoryModel category) async {
    writes++;
    createdCategoryNames.add(category.name);
    // Like the server: only the name survives a create.
    final created = CategoryModel(
      _nextId++,
      1,
      category.name,
      'empty',
      false,
      false,
      '#ffffff',
    );
    categoryList.add(created);
    return created;
  }

  @override
  Future update(dynamic model) async {
    writes++;
    if (model is CategoryModel) {
      final i = categoryList.indexWhere((c) => c.id == model.id);
      categoryList[i] = CategoryModel(
        model.id,
        1,
        model.name,
        model.icon,
        model.measurable,
        model.isActive,
        model.color,
      );
    } else if (model is AccountModel) {
      final a = account(model.id);
      a.name = model.name;
      a.archive = model.archive;
      a.measurable = model.measurable;
      a.isHidden = model.isHidden;
    }
  }

  @override
  Future delete(dynamic model) => throw UnimplementedError();

  @override
  Future<List<AccountModel>> fetchAccounts() async => [
    for (final a in accountList)
      AccountModel(
        a.id,
        a.name,
        a.balance,
        a.measurable,
        a.accountType,
        a.currencyId,
        a.userId,
        a.archive,
        a.isHidden,
      ),
  ];

  @override
  Future<bool> hasTransactions(int accountId) async =>
      (transactionCount[accountId] ?? 0) > 0;

  @override
  Future<void> bulkAdd(List<TransactionModel> transactions) async {
    writes++;
    bulkRequests.add(transactions);
    accountNamesAtBulk.add([for (final a in accountList) a.name]);
    for (final t in transactions) {
      final a = account(t.accountId);
      a.balance += t.transactionType == TransactionType.Income
          ? t.amount
          : -t.amount;
      transactionCount[a.id] = (transactionCount[a.id] ?? 0) + 1;
    }
    account(transactions.first.accountId).balance += balanceSkew;
    if (failAfterApplyingBulkCall == bulkRequests.length) {
      throw Exception('connection lost');
    }
  }
}

// Declared on the server fake above through the account seam.
extension on FakeServer {
  Future<AccountModel> addAccount(AccountModel account) async {
    writes++;
    // Like the server: archive, measurable and isHidden are not taken on create.
    final created = AccountModel(
      _nextId++,
      account.name,
      0,
      true,
      account.accountType,
      account.currencyId,
      1,
      false,
      false,
    );
    accountList.add(created);
    return created;
  }
}

void main() {
  late LocalDatabase db;
  late FakeServer server;
  late LocalImportService service;

  // Local ids, filled by [seedLocal].
  late int cash, savings, travel, empty;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    server = FakeServer();
    service = LocalImportService(
      database: db,
      accounts: _AccountsOf(server),
      categories: server,
      currencies: server,
      transactions: server,
    );
  });
  tearDown(() => db.close());

  Future<int> addAccount(
    String name, {
    int type = 0,
    int currencyId = 1,
    bool measurable = true,
    bool archive = false,
    bool hidden = false,
  }) => db
      .into(db.accounts)
      .insert(
        AccountsCompanion.insert(
          name: name,
          accountType: type,
          currencyId: currencyId,
          measurable: Value(measurable),
          archive: Value(archive),
          isHidden: Value(hidden),
        ),
      );

  Future<int> categoryId(String name) async => (await (db.select(
    db.categories,
  )..where((c) => c.nameKey.equals(categoryNameKey(name)))).getSingle()).id;

  Future<void> addTx(
    int accountId,
    String name,
    double amount,
    TransactionType type,
    int category, {
    DateTime? date,
  }) async {
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            categoryId: category,
            name: name,
            amount: amount,
            transactionType: type.index,
            date: date ?? DateTime.utc(2026, 3, 1),
            createdAt: DateTime.utc(2026, 3, 1),
          ),
        );
  }

  /// The server's default categories, as it would have them: same names, but
  /// different ids and different casing.
  Future<void> seedServerCategories() async {
    var id = 100;
    for (final c in await db.select(db.categories).get()) {
      server.categoryList.add(
        CategoryModel(
          id++,
          1,
          c.name.toUpperCase(),
          c.icon,
          true,
          true,
          '#ffffff',
        ),
      );
    }
  }

  Future<void> seedLocal({bool withCash = true}) async {
    await seedServerCategories();
    final rent = await categoryId('Rent');
    final salary = await categoryId('Salary');
    cash = withCash ? await addAccount('Cash') : -1;
    savings = await addAccount('Savings', type: 1);
    travel = await addAccount(
      'Travel',
      currencyId: 2,
      measurable: false,
      archive: true,
      hidden: true,
    );
    empty = await addAccount('Empty');
    if (withCash) {
      await addTx(cash, 'Pay', 1000, TransactionType.Income, salary);
      await addTx(cash, 'Bus', 12.5, TransactionType.Outcome, rent);
    }
    await addTx(savings, 'Deposit', 300, TransactionType.Income, salary);
    // Named like a real account: the server would mirror it if "Cash" existed
    // under that name while this request is processed.
    await addTx(savings, 'Cash', 40, TransactionType.Outcome, rent);
    await addTx(travel, 'Hotel', 80.25, TransactionType.Outcome, rent);
  }

  Future<LocalImportState> importState() =>
      (db.select(db.importStates)..where((s) => s.id.equals(1))).getSingle();

  Future<LocalAccount> local(int id) =>
      (db.select(db.accounts)..where((a) => a.id.equals(id))).getSingle();

  test('imports everything and maps every id', () async {
    await seedLocal();
    final rent = await categoryId('Rent');

    final result = await service.run(email: 'a@b.com');

    expect(result.mismatches, isEmpty);
    // Three accounts have transactions, one does not.
    expect(server.bulkRequests, hasLength(3));
    final localSavings = await local(savings);
    final serverRentId = (await (db.select(
      db.categories,
    )..where((c) => c.id.equals(rent))).getSingle()).serverId;
    expect(serverRentId, 101);
    final sent = server.bulkRequests.firstWhere(
      (r) => r.first.accountId == localSavings.serverId,
    );
    expect(sent, hasLength(2));
    expect(sent.map((t) => t.categoryId), everyElement(isIn([101, 109])));
    expect(sent.every((t) => t.accountId == localSavings.serverId), isTrue);
    expect(sent.firstWhere((t) => t.name == 'Cash').amount, 40);

    for (final id in [cash, savings, travel, empty]) {
      final a = await local(id);
      expect(a.serverId, isNotNull);
      final remote = server.account(a.serverId!);
      expect(remote.balance, closeTo(await db.accountBalance(id), 0.005));
    }
    final state = await importState();
    expect(state.status, ImportStatus.completed);
    expect(state.targetEmail, 'a@b.com');
    expect(state.importTag, matches(RegExp(r'^[0-9a-f]{8}$')));
  });

  test(
    'default categories are matched by name, ignoring case, and not created',
    () async {
      await seedLocal();

      await service.run(email: 'a@b.com');

      expect(server.createdCategoryNames, isEmpty);
      expect(server.categoryList, hasLength(17));
      final rows = await db.select(db.categories).get();
      expect(rows.every((c) => c.serverId != null), isTrue);
    },
  );

  test(
    'a created category is updated with active, icon, color and measurable',
    () async {
      await seedLocal();
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Pets',
              icon: 'pets',
              nameKey: Value(categoryNameKey('Pets')),
              color: const Value('#123456'),
              measurable: const Value(false),
              isActive: const Value(false),
            ),
          );

      await service.run(email: 'a@b.com');

      expect(server.createdCategoryNames, ['Pets']);
      final pets = server.categoryList.singleWhere((c) => c.name == 'Pets');
      expect(pets.icon, 'pets');
      expect(pets.color, '#123456');
      expect(pets.measurable, isFalse);
      expect(pets.isActive, isFalse);
    },
  );

  test(
    'the local Cash/USD account is mapped to the server default Cash',
    () async {
      await seedLocal();

      await service.run(email: 'a@b.com');

      expect((await local(cash)).serverId, 1);
      expect(server.accountList.where((a) => a.name == 'Cash'), hasLength(1));
      expect((await importState()).defaultAccountServerId, isNull);
    },
  );

  test(
    'an unmapped server default account is renamed while sending and restored',
    () async {
      await seedLocal(withCash: false);

      await service.run(email: 'a@b.com');

      final tag = (await importState()).importTag!;
      expect(server.accountNamesAtBulk, isNotEmpty);
      for (final names in server.accountNamesAtBulk) {
        expect(
          names,
          contains(LocalImportService.temporaryName('Cash', tag, 'default')),
        );
        expect(names, isNot(contains('Cash')));
      }
      expect(server.account(1).name, 'Cash');
      expect((await importState()).defaultAccountServerId, 1);
    },
  );

  test('every server account has a temporary name when a bulk request is sent, '
      'and the real names, flags come back after', () async {
    await seedLocal();

    await service.run(email: 'a@b.com');

    for (final names in server.accountNamesAtBulk) {
      expect(names, isNotEmpty);
      expect(
        names.every((n) => n.contains('⟨import ')),
        isTrue,
        reason: 'a transaction named like a real account must match nothing',
      );
    }
    final names = server.accountList.map((a) => a.name).toSet();
    expect(names, {'Cash', 'Savings', 'Travel', 'Empty'});
    final travelServer = server.account((await local(travel)).serverId!);
    expect(travelServer.archive, isTrue);
    expect(travelServer.measurable, isFalse);
    expect(travelServer.isHidden, isTrue);
    final savingsServer = server.account((await local(savings)).serverId!);
    expect(savingsServer.accountType, AccountType.BankAccount);
  });

  test('accounts without transactions are never sent', () async {
    await seedLocal();

    await service.run(email: 'a@b.com');

    final emptyServerId = (await local(empty)).serverId;
    expect(emptyServerId, isNotNull);
    expect(
      server.bulkRequests.any((r) => r.first.accountId == emptyServerId),
      isFalse,
    );
  });

  test(
    'an unknown currency aborts before anything is written (FR-020)',
    () async {
      await seedLocal();
      await addAccount('Euros', currencyId: 3); // EUR is not on this server

      await expectLater(
        service.run(email: 'a@b.com'),
        throwsA(
          isA<ImportCurrencyMissingException>().having(
            (e) => e.codes,
            'codes',
            ['EUR'],
          ),
        ),
      );

      expect(server.writes, 0);
      final state = await importState();
      expect(state.status, ImportStatus.failed);
      expect(state.lastError, isNotNull);
    },
  );

  test(
    'a failure while sending is retried without sending twice (SC-006)',
    () async {
      await seedLocal();
      server.failAfterApplyingBulkCall = 2;

      await expectLater(service.run(email: 'a@b.com'), throwsException);

      var state = await importState();
      expect(state.status, ImportStatus.failed);
      expect(state.lastError, contains('connection lost'));
      final imported = (await db.select(db.accounts).get()).where(
        (a) => a.transactionsImported,
      );
      expect(
        imported,
        hasLength(1),
        reason: 'only the first bulk was confirmed',
      );

      server.failAfterApplyingBulkCall = null;
      final result = await service.run(email: 'a@b.com');

      // The second account was applied but never confirmed: it is detected on the
      // server and marked, not sent again.
      expect(server.bulkRequests, hasLength(3));
      expect(result.mismatches, isEmpty);
      for (final id in [cash, savings, travel]) {
        final a = await local(id);
        expect(a.transactionsImported, isTrue);
        expect(
          server.account(a.serverId!).balance,
          closeTo(await db.accountBalance(id), 0.005),
        );
      }
      state = await importState();
      expect(state.status, ImportStatus.completed);
    },
  );

  test(
    'after a failure the local data is read-only, and the retry matches it',
    () async {
      await seedLocal();
      final appMode = AppModeService(
        FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => db,
      );
      SharedPreferences.setMockInitialValues({});
      await appMode.init();
      await appMode.enterLocalMode();
      final localAccounts = ModeAwareAccountDataSource(
        _AccountsOf(server),
        appMode,
      );
      server.failAfterApplyingBulkCall = 2;
      await expectLater(service.run(email: 'a@b.com'), throwsException);
      await appMode.refreshImportStatus();

      await expectLater(
        localAccounts.add(
          AccountModel(
            0,
            'Late',
            0,
            true,
            AccountType.Cash,
            1,
            0,
            false,
            false,
          ),
        ),
        throwsA(isA<LocalDataLockedException>()),
      );

      server.failAfterApplyingBulkCall = null;
      final result = await service.run(email: 'a@b.com');

      expect(result.mismatches, isEmpty);
      expect(
        (await db.select(db.accounts).get()).map((a) => a.name),
        isNot(contains('Late')),
      );
      for (final id in [cash, savings, travel]) {
        final a = await local(id);
        expect(
          server.account(a.serverId!).balance,
          closeTo(await db.accountBalance(id), 0.005),
        );
      }
    },
  );

  test('a retry by another user is refused', () async {
    await seedLocal();
    server.failAfterApplyingBulkCall = 1;
    await expectLater(service.run(email: 'a@b.com'), throwsException);
    final writes = server.writes;

    await expectLater(
      service.run(email: 'other@b.com'),
      throwsA(isA<ImportWrongUserException>()),
    );

    expect(server.writes, writes);
  });

  test('a balance mismatch is reported, not hidden (FR-023)', () async {
    await seedLocal();
    server.balanceSkew = 5;

    final result = await service.run(email: 'a@b.com');

    expect(result.mismatches, isNotEmpty);
    final m = result.mismatches.first;
    expect(m.serverBalance - m.localBalance, closeTo(5, 0.005));
    expect(m.accountName, isNotEmpty);
  });

  test(
    'an account created before a crash is found by its temporary name',
    () async {
      await seedLocal();
      // An earlier attempt created "Savings" but died before storing server_id.
      await (db.update(db.importStates)..where((s) => s.id.equals(1))).write(
        ImportStatesCompanion(
          status: const Value(ImportStatus.inProgress),
          targetEmail: const Value('a@b.com'),
          importTag: const Value('deadbeef'),
        ),
      );
      final orphan = AccountModel(
        777,
        LocalImportService.temporaryName('Savings', 'deadbeef', savings),
        0,
        true,
        AccountType.BankAccount,
        10,
        1,
        false,
        false,
      );
      server.accountList.add(orphan);

      await service.run(email: 'a@b.com');

      expect((await local(savings)).serverId, 777);
      expect(
        server.accountList.where((a) => a.name == 'Savings'),
        hasLength(1),
      );
      expect(
        server.accountList.where((a) => a.name.startsWith('Savings')),
        hasLength(1),
      );
    },
  );

  test('progress is reported for every step', () async {
    await seedLocal();
    final steps = <ImportStep>{};
    var lastTransactions = (0, 0);

    await service.run(
      email: 'a@b.com',
      onProgress: (step, done, total) {
        steps.add(step);
        if (step == ImportStep.transactions) lastTransactions = (done, total);
      },
    );

    expect(steps, ImportStep.values.toSet());
    expect(lastTransactions, (3, 3));
  });
}

/// The account seam, with the creation behaviour of [FakeServer] (kept in an
/// extension so the shared class stays readable).
class _AccountsOf implements AccountDataSource {
  final FakeServer server;
  _AccountsOf(this.server);

  @override
  Future<AccountModel> add(AccountModel account) => server.addAccount(account);

  @override
  Future delete(AccountModel account) => server.delete(account);

  @override
  Future<List<AccountModel>> fetchAccounts() => server.fetchAccounts();

  @override
  Future update(AccountModel account) => server.update(account);
}
