import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations_en.dart';
import 'package:home_management_app/l10n/app_localizations_es.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

class _UnreachableAccounts implements AccountDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableCategories implements CategoryDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableTransactions implements TransactionDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableTransactionService implements TransactionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

Future<void> breakWrites(LocalDatabase db, String table) async {
  for (final operation in ['INSERT', 'UPDATE', 'DELETE']) {
    await db.customStatement(
        "CREATE TRIGGER fail_${table}_$operation BEFORE $operation ON $table "
        "BEGIN SELECT RAISE(ABORT, 'database or disk is full'); END");
  }
}

void main() {
  const english = "Your change couldn't be saved. Nothing was changed.";

  late AppModeService appMode;
  late NotifierService notifier;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late TransactionRepository transactions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();

    notifier = NotifierService();
    accounts = AccountRepository(
        accountService: ModeAwareAccountDataSource(_UnreachableAccounts(), appMode),
        notifierService: notifier);
    categories = CategoryRepository(
        ModeAwareCategoryDataSource(_UnreachableCategories(), appMode),
        notifierService: notifier);
    transactions = TransactionRepository(
        transactionService: _UnreachableTransactionService(),
        dataSource: ModeAwareTransactionDataSource(_UnreachableTransactions(), appMode),
        accountRepository: accounts,
        errorNotifierService: notifier);

    await accounts.add(AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false));
    await categories.load();
    notifier.getMessage(); // drop the "added" notice
  });

  tearDown(() => appMode.database!.close());

  void expectNotSavedNotice() {
    expect(notifier.hasError, isTrue);
    expect(notifier.getMessage(), english);
  }

  group('transactions', () {
    late AccountModel account;
    late TransactionModel income;

    setUp(() async {
      account = accounts.getAllAccounts().single;
      await transactions.loadFirstPage(account.id);
      await transactions.add(
          TransactionModel(0, account.id, 1, 'Pay', 100, DateTime(2026, 1, 1), TransactionType.Income));
      await transactions.loadFirstPage(account.id);
      income = transactions.transactions.single;
      notifier.getMessage();
      await breakWrites(appMode.database!, 'transactions');
    });

    test('a failed add keeps the list and the balance, and says so', () async {
      await transactions.add(
          TransactionModel(0, account.id, 1, 'Coffee', 5, DateTime(2026, 1, 2), TransactionType.Outcome));

      expect(accounts.getAllAccounts().single.balance, closeTo(100, 0.001));
      expect(transactions.transactions, hasLength(1));
      expectNotSavedNotice();
    });

    test('a failed edit keeps the list and the balance, and says so', () async {
      await transactions.update(income.clone()..amount = 250);

      expect(accounts.getAllAccounts().single.balance, closeTo(100, 0.001));
      expect(transactions.transactions.single.amount, 100);
      expectNotSavedNotice();
    });

    test('a failed remove keeps the list and the balance, and says so', () async {
      await transactions.remove(income);

      expect(accounts.getAllAccounts().single.balance, closeTo(100, 0.001));
      expect(transactions.transactions, hasLength(1));
      expectNotSavedNotice();
    });
  });

  group('accounts', () {
    late AccountModel account;

    setUp(() async {
      account = accounts.getAllAccounts().single;
      await breakWrites(appMode.database!, 'accounts');
    });

    test('a failed add adds nothing', () async {
      await accounts.add(AccountModel(0, 'Other', 0, true, AccountType.Cash, 1, 0, false, false));

      expect(accounts.accounts, hasLength(1));
      expectNotSavedNotice();
    });

    test('a failed edit puts the stored values back', () async {
      account.name = 'Renamed';
      await accounts.update(account);

      expect(accounts.getAllAccounts().single.name, 'Main');
      expect(accounts.accounts.single.name, 'Main');
      expectNotSavedNotice();
    });

    test('a failed archive and a failed hide undo their toggle', () async {
      await accounts.archive(account);
      expect(account.archive, isFalse);
      expectNotSavedNotice();

      await accounts.hide(account);
      expect(account.isHidden, isFalse);
      expectNotSavedNotice();
    });

    test('a failed delete keeps the account', () async {
      await accounts.delete(account);

      expect(accounts.accounts, hasLength(1));
      expectNotSavedNotice();
    });
  });

  group('categories', () {
    setUp(() => breakWrites(appMode.database!, 'categories'));

    test('a failed add adds nothing', () async {
      await categories.add(CategoryModel(0, 0, 'Pets', 'pets', true, true, '#ffffff'));

      expect(categories.categories, hasLength(17));
      expectNotSavedNotice();
    });

    test('a failed edit puts the stored values back', () async {
      final rent = categories.categories.firstWhere((c) => c.name == 'Rent');
      rent.name = 'Housing';
      await categories.update(rent);

      expect(categories.categories.map((c) => c.name), contains('Rent'));
      expect(categories.categories.map((c) => c.name), isNot(contains('Housing')));
      expectNotSavedNotice();
    });

    test('a failed delete keeps the category', () async {
      await categories.delete(categories.categories.first);

      expect(categories.categories, hasLength(17));
      expectNotSavedNotice();
    });
  });

  group('the notice', () {
    test('is shown in the language of the view', () {
      notifier.notifyChangeNotSaved();

      expect(notifier.getMessage(l10n: AppLocalizationsEs()),
          'No se pudo guardar el cambio. No se modificó nada.');
    });

    test('falls back to English without localizations', () {
      notifier.notifyChangeNotSaved();

      expect(notifier.getMessage(), AppLocalizationsEn().changeNotSaved);
    });

    test('is consumed once', () {
      notifier.notifyChangeNotSaved();
      notifier.getMessage();

      expect(notifier.getMessage(), isNull);
    });
  });
}
