import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/accounts/views/account-list-desktop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';
import '../helpers/storage_failures.dart';

class _UnreachableAccounts implements AccountDataSource {
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

void main() {
  late AppModeService appMode;
  late AccountRepository accounts;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();

    final notifier = NotifierService();
    accounts = AccountRepository(
        accountService: ModeAwareAccountDataSource(_UnreachableAccounts(), appMode),
        notifierService: notifier);
    final transactions = TransactionRepository(
        transactionService: _UnreachableTransactionService(),
        dataSource: ModeAwareTransactionDataSource(_UnreachableTransactions(), appMode),
        accountRepository: accounts,
        errorNotifierService: notifier);
    GetIt.I
      ..registerSingleton<NotifierService>(notifier)
      ..registerSingleton<AccountRepository>(accounts)
      ..registerSingleton<TransactionRepository>(transactions)
      ..registerSingleton<TransactionService>(_UnreachableTransactionService())
      ..registerSingleton<PlatformContext>(FakePlatform(PlatformType.Desktop));

    await accounts.add(AccountModel(0, 'Used', 0, true, AccountType.Cash, 1, 0, false, false));
    await accounts.add(AccountModel(0, 'Empty', 0, true, AccountType.Cash, 1, 0, false, false));
    final used = accounts.getAllAccounts().firstWhere((a) => a.name == 'Used');
    await transactions.loadFirstPage(used.id);
    await transactions.add(
        TransactionModel(0, used.id, 1, 'Pay', 10, DateTime(2026, 1, 1), TransactionType.Income));
    notifier.getMessage();
  });

  tearDown(() async {
    await appMode.database!.close();
    await GetIt.I.reset();
  });

  Future<void> pumpList(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AccountListDesktopView()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> deleteAccount(WidgetTester tester, String name) async {
    final row = find.ancestor(of: find.text(name), matching: find.byType(Card)).first;
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
  }

  testWidgets('deleting an empty account removes it and says so', (tester) async {
    await pumpList(tester);

    await deleteAccount(tester, 'Empty');

    expect(find.text('Empty'), findsNothing);
    expect(find.text('Used'), findsOneWidget);
    // The repository's notice is the visible one. The view's "removed" snackbar queues behind it.
    expect(find.text('Account Empty deleted successfully'), findsOneWidget);
  });

  testWidgets('an account with transactions stays and the reason is shown', (tester) async {
    await pumpList(tester);

    await deleteAccount(tester, 'Used');

    expect(find.text('Used'), findsOneWidget);
    expect(find.textContaining("can't be deleted"), findsOneWidget);
  });

  testWidgets('a failed delete keeps the account and does not say it was removed', (tester) async {
    await pumpList(tester);
    await makeStorageReadOnly(appMode.database!);

    await deleteAccount(tester, 'Empty');

    expect(find.text('Empty'), findsOneWidget, reason: 'it is still stored');
    expect(find.text("Your change couldn't be saved. Nothing was changed."), findsOneWidget);
    expect(find.textContaining('removed'), findsNothing);
  });
}
