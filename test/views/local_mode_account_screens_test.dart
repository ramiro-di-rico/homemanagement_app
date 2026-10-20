import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/accounts/views/account-detail-desktop.dart';
import 'package:home_management_app/ui/features/accounts/views/account-list-desktop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

class _UnreachableAccounts implements AccountDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableCategories implements CategoryDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableCurrencies implements CurrencyDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

class _UnreachableTransactions implements TransactionDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

/// `TransactionRepository` keeps the concrete service for server-only calls.
class _NeverUsedTransactionService implements TransactionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

/// Account list and account detail. Neither `MetricService` nor `TransactionService`
/// is registered, so a local-mode screen that asked GetIt for one would throw: that
/// is how these tests prove the screens make no server call (FR-004).
void main() {
  late AppModeService appMode;
  late AccountRepository accounts;
  late TransactionRepository transactions;
  late AccountModel main;

  Future<void> setUpApp({required bool local}) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode(); // the data lives in the local database either way
    final notifier = NotifierService();
    accounts = AccountRepository(
        accountService: ModeAwareAccountDataSource(_UnreachableAccounts(), appMode),
        notifierService: notifier);
    transactions = TransactionRepository(
        transactionService: _NeverUsedTransactionService(),
        dataSource: ModeAwareTransactionDataSource(_UnreachableTransactions(), appMode),
        accountRepository: accounts,
        errorNotifierService: notifier);
    final categories = CategoryRepository(
        ModeAwareCategoryDataSource(_UnreachableCategories(), appMode),
        notifierService: notifier);
    final currencies = CurrencyRepository(
        currencyService: ModeAwareCurrencyDataSource(_UnreachableCurrencies(), appMode));
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton<NotifierService>(notifier)
      ..registerSingleton<AccountRepository>(accounts)
      ..registerSingleton<CategoryRepository>(categories)
      ..registerSingleton<CurrencyRepository>(currencies)
      ..registerSingleton<TransactionRepository>(transactions)
      ..registerSingleton<PlatformContext>(
          FakePlatform(PlatformType.Desktop, canDownload: true, canUpload: true));
    await currencies.load();
    await categories.load();
    await accounts.add(AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false));
    main = accounts.getAllAccounts().single;
    if (!local) await appMode.leaveLocalMode();
  }

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: screen),
    ));
    await tester.pumpAndSettle();
  }

  const csvItems = ['Export transactions', 'Download import template', 'Import Transactions'];

  group('account list', () {
    Future<void> openMenu(WidgetTester tester) async {
      final row = find.ancestor(of: find.text('Main'), matching: find.byType(Card)).first;
      await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.more_vert)));
      await tester.pumpAndSettle();
    }

    testWidgets('in local mode has no CSV export or import, and makes no server call', (tester) async {
      await setUpApp(local: true);
      await accounts.load();
      await pump(tester, AccountListDesktopView());

      await openMenu(tester);

      for (final item in csvItems) {
        expect(find.text(item), findsNothing, reason: item);
      }
      expect(find.text('Delete'), findsOneWidget, reason: 'the local actions are still there');
    });

    testWidgets('online it still offers them, so only local mode loses them', (tester) async {
      // The account is created locally and stays in memory when the mode flips.
      await setUpApp(local: false);
      await pump(tester, AccountListDesktopView());

      await openMenu(tester);

      for (final item in csvItems) {
        expect(find.text(item), findsOneWidget, reason: item);
      }
    });
  });

  group('account detail in local mode', () {
    setUp(() => setUpApp(local: true));

    Future<void> openDetail(WidgetTester tester) async {
      await pump(tester, AccountDetailDesktop(main));
    }

    testWidgets('shows the account and its transactions without any server call', (tester) async {
      await openDetail(tester);

      expect(find.text('Account: Main'), findsOneWidget);
      expect(find.byType(AccountDetailDesktop), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('has no metrics panels, even for an account that is measurable', (tester) async {
      expect(main.measurable, isTrue);
      await openDetail(tester);

      expect(find.byWidgetPredicate((w) => w.runtimeType.toString().contains('MostExpensive')), findsNothing);
      expect(find.byWidgetPredicate((w) => w.runtimeType.toString() == 'OverviewWidget'), findsNothing);
    });

    testWidgets('keeps edit and archive, and drops CSV import and reconciliation', (tester) async {
      await openDetail(tester);

      await tester.tap(find.byTooltip('Show menu'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Account'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Import Transactions'), findsNothing);
      expect(find.text('Reconcile statement'), findsNothing);
    });

    testWidgets('lists the most recent transaction first', (tester) async {
      await transactions.loadFirstPage(main.id);
      for (final (name, day) in [('Old', 1), ('Newest', 20), ('Middle', 10)]) {
        await transactions.add(TransactionModel(
            0, main.id, 1, name, 5, DateTime(2026, 3, day), TransactionType.Outcome));
      }

      await openDetail(tester);

      final names = ['Newest', 'Middle', 'Old'];
      final positions = names.map((n) => tester.getTopLeft(find.text(n)).dy).toList();
      expect(positions, [...positions]..sort(), reason: 'top to bottom: $names');
    });
  });
}

