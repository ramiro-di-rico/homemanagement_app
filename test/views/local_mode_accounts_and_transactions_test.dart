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
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/custom/components/app-textfield.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/transaction.row.info.dart';
import 'package:home_management_app/ui/features/home/views/shared/account-sheet-dektop.dart';
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

class _UnreachableTransactionService implements TransactionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('reached the server');
}

void main() {
  late AppModeService appMode;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late CurrencyRepository currencies;
  late TransactionRepository transactions;

  Future<void> setUpApp({required bool local}) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    if (local) await appMode.enterLocalMode();

    final notifier = NotifierService();
    accounts = AccountRepository(
        accountService: ModeAwareAccountDataSource(_UnreachableAccounts(), appMode),
        notifierService: notifier);
    categories = CategoryRepository(
        ModeAwareCategoryDataSource(_UnreachableCategories(), appMode),
        notifierService: notifier);
    currencies = CurrencyRepository(
        currencyService: ModeAwareCurrencyDataSource(_UnreachableCurrencies(), appMode));
    transactions = TransactionRepository(
        transactionService: _UnreachableTransactionService(),
        dataSource: ModeAwareTransactionDataSource(_UnreachableTransactions(), appMode),
        accountRepository: accounts,
        errorNotifierService: notifier);
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton<NotifierService>(notifier)
      ..registerSingleton<AccountRepository>(accounts)
      ..registerSingleton<CategoryRepository>(categories)
      ..registerSingleton<CurrencyRepository>(currencies)
      ..registerSingleton<TransactionRepository>(transactions);
  }

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<void> pumpApp(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ));
    await tester.pumpAndSettle();
  }

  group('creating an account from the desktop sheet', () {
    setUp(() async {
      await setUpApp(local: true);
      await currencies.load();
    });

    Future<AccountModel> createWallet(WidgetTester tester, List<String> pickCurrencies) async {
      await pumpApp(tester, AccountSheetDesktop());
      await tester.enterText(find.byType(AppTextField), 'Wallet');
      await tester.pump();
      for (final currency in pickCurrencies) {
        await tester.tap(find.byType(DropdownButton<String>).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(currency).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      return (await ModeAwareAccountDataSource(_UnreachableAccounts(), appMode).fetchAccounts())
          .singleWhere((a) => a.name == 'Wallet');
    }

    testWidgets('offers the three local currencies', (tester) async {
      await pumpApp(tester, AccountSheetDesktop());
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();

      for (final code in ['USD', 'ARS', 'EUR']) {
        expect(find.text(code), findsWidgets);
      }
    });

    testWidgets('keeps USD when the currency is left alone', (tester) async {
      final wallet = await createWallet(tester, []);

      expect(wallet.currencyId, 1);
    });

    testWidgets('saves the chosen currency, not its position in the list', (tester) async {
      final ars = await createWallet(tester, ['ARS']);
      expect(ars.currencyId, 2);
    });

    testWidgets('saves EUR', (tester) async {
      final eur = await createWallet(tester, ['EUR']);
      expect(eur.currencyId, 3);
    });

    testWidgets('going back to USD after another choice still saves USD', (tester) async {
      final usd = await createWallet(tester, ['ARS', 'USD']);
      expect(usd.currencyId, 1, reason: 'the position of USD is 0, which is not a currency');
    });
  });

  group('a transaction row', () {
    late AccountModel account;
    late TransactionModel stored;

    Future<void> pumpRow(WidgetTester tester) async {
      await pumpApp(
          tester,
          ListView(children: [
            TransactionRowInfo(
              transaction: stored,
              category: categories.categories.first,
              index: 0,
              account: account,
            ),
          ]));
    }

    Future<void> setUpRow() async {
      await setUpApp(local: true);
      await currencies.load();
      await categories.load();
      await accounts.add(AccountModel(0, 'Main', 0, true, AccountType.Cash, 1, 0, false, false));
      account = accounts.getAllAccounts().single;
      await transactions.loadFirstPage(account.id);
      await transactions.add(TransactionModel(
          0, account.id, categories.categories.first.id, 'Coffee', 4, DateTime(2026, 3, 2), TransactionType.Outcome));
      await transactions.loadFirstPage(account.id);
      stored = transactions.transactions.single;
    }

    Future<void> swipeOpen(WidgetTester tester) async {
      await tester.drag(find.byType(ListTile), const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    group('in local mode', () {
      setUp(setUpRow);

      testWidgets('has no tag controls', (tester) async {
        await pumpRow(tester);
        expect(find.text('Add tag'), findsNothing);
        expect(find.byIcon(Icons.label_outline), findsNothing);

        await swipeOpen(tester);
        expect(find.byIcon(Icons.label_outline), findsNothing);
        expect(find.byIcon(Icons.copy), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('duplicating adds a second transaction and moves the balance', (tester) async {
        await pumpRow(tester);
        await swipeOpen(tester);

        await tester.tap(find.byIcon(Icons.copy));
        await tester.pumpAndSettle();

        expect(transactions.transactions.map((t) => t.name), ['Coffee', 'Coffee']);
        expect(accounts.getAllAccounts().single.balance, closeTo(-8, 0.001));
        final stored = await ModeAwareAccountDataSource(_UnreachableAccounts(), appMode).fetchAccounts();
        expect(stored.single.balance, closeTo(-8, 0.001));
      });

      testWidgets('deleting removes it and gives the amount back', (tester) async {
        await pumpRow(tester);
        await swipeOpen(tester);

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(transactions.transactions, isEmpty);
        expect(accounts.getAllAccounts().single.balance, closeTo(0, 0.001));
      });
    });

    testWidgets('while online it still has the tag controls', (tester) async {
      await setUpApp(local: false);
      await pumpApp(
          tester,
          ListView(children: [
            TransactionRowInfo(
              transaction: TransactionModel(
                  5, 1, 1, 'Coffee', 4, DateTime(2026, 3, 2), TransactionType.Outcome),
              category: CategoryModel(1, 0, 'Rent', 'home', true, true, '#ffffff'),
              index: 0,
              account: AccountModel(1, 'Main', 0, true, AccountType.Cash, 1, 0, false, false),
            ),
          ]));

      expect(find.text('Add tag'), findsOneWidget);
    });
  });
}
