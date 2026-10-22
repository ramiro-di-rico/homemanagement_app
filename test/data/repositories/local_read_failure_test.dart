import 'package:flutter_test/flutter_test.dart';
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
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';
import '../../helpers/storage_failures.dart';

String _reached(Invocation invocation) =>
    'Local mode reached the server: ${invocation.memberName}';

class _UnreachableAccounts implements AccountDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(_reached(invocation));
}

class _UnreachableCategories implements CategoryDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(_reached(invocation));
}

class _UnreachableTransactions implements TransactionDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(_reached(invocation));
}

class _UnreachableTransactionService implements TransactionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(_reached(invocation));
}

/// What the user sees when the disk fails while reading: a notice, and the screen
/// keeps what it was showing (RF-19), instead of a raw database error.
void main() {
  const notice = "Your data couldn't be read. Nothing was changed.";

  late FailingReads failing;
  late AppModeService appMode;
  late NotifierService notifier;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late TransactionRepository transactions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    failing = FailingReads();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => openWithFailingReads(failing));
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
    await accounts.load();
    notifier.getMessage();
  });

  tearDown(() => appMode.database!.close());

  test('a failed account load keeps the accounts that were shown, and says why', () async {
    failing.error = diskIoError();

    await accounts.load();

    expect(accounts.getAllAccounts().map((a) => a.name), ['Main']);
    expect(notifier.hasError, isTrue);
    expect(notifier.getMessage(), notice);
  });

  test('a failed category load keeps the categories that were shown, and says why', () async {
    failing.error = diskIoError();

    await categories.load();

    expect(categories.categories, hasLength(17));
    expect(notifier.getMessage(), notice);
  });

  test('a failed page of transactions keeps the list, and says why', () async {
    final account = accounts.getAllAccounts().single;
    await transactions.loadFirstPage(account.id);
    await transactions.add(TransactionModel(
        0, account.id, 1, 'Pay', 10, DateTime(2026, 1, 1), TransactionType.Income));
    notifier.getMessage();
    final shown = transactions.transactions.length;
    failing.error = diskIoError();

    await transactions.loadFirstPage(account.id);

    expect(shown, 1);
    expect(notifier.getMessage(), notice);
  });

  test('once the disk works again, loading works', () async {
    failing.error = diskIoError();
    await accounts.load();
    notifier.getMessage();
    failing.error = null;

    await accounts.load();

    expect(accounts.getAllAccounts(), hasLength(1));
    expect(notifier.getMessage(), isNull);
  });

  test('an error that is not about the storage still surfaces, not hidden behind that notice',
      () async {
    failing.error = sqlLogicError();

    await expectLater(accounts.load(), throwsA(anything));
    expect(notifier.getMessage(), isNull);
  });
}
