import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/accounts/views/account-list-desktop.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:home_management_app/ui/features/home/views/shared/account-sheet-dektop.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_home_desktop.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_mode_banner.dart';
import 'package:home_management_app/ui/features/settings/views/settings.dart';
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
  late GoRouter router;

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
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton<NotifierService>(notifier)
      ..registerSingleton<AccountRepository>(accounts)
      ..registerSingleton<CategoryRepository>(
          CategoryRepository(ModeAwareCategoryDataSource(_UnreachableCategories(), appMode), notifierService: notifier))
      ..registerSingleton<CurrencyRepository>(
          CurrencyRepository(currencyService: ModeAwareCurrencyDataSource(_UnreachableCurrencies(), appMode)))
      ..registerSingleton<TransactionRepository>(transactions)
      ..registerSingleton<TransactionService>(_UnreachableTransactionService())
      ..registerSingleton<PlatformContext>(FakePlatform(PlatformType.Desktop));
  });

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    router = GoRouter(initialLocation: HomeScreen.fullPath, routes: [
      GoRoute(path: HomeScreen.fullPath, builder: (_, _) => const LocalHomeDesktop()),
      GoRoute(path: SettingsScreen.fullPath, builder: (_, _) => const Text('SETTINGS SCREEN')),
      GoRoute(path: RegistrationScreen.fullPath, builder: (_, _) => const Text('REGISTRATION SCREEN')),
      GoRoute(path: LoginView.fullPath, builder: (_, _) => const Text('LOGIN SCREEN')),
    ]);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
  }

  Future<void> addAccount(String name) => accounts.add(
      AccountModel(0, name, 0, true, AccountType.Cash, 1, 0, false, false));

  const signInAction = 'Sign in to an existing account';
  const createAction = 'Create online account';

  group('the app bar', () {
    setUp(() => addAccount('Main'));

    testWidgets('has only what works without a server', (tester) async {
      await pumpHome(tester);

      expect(find.text(createAction), findsNWidgets(2), reason: 'app bar and banner');
      expect(find.text(signInAction), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      for (final server in [
        Icons.manage_search, // search
        Icons.playlist_add, // bulk
        Icons.mail_outline, // invitations
        Icons.bar_chart, // statistics
        Icons.track_changes, // budget
        Icons.notifications, // reminders
        Icons.logout,
      ]) {
        expect(find.byIcon(server), findsNothing, reason: '$server needs the server');
      }
    });

    testWidgets('shows the local-mode banner, which also offers an online account', (tester) async {
      await pumpHome(tester);

      expect(find.byType(LocalModeBanner), findsOneWidget);
      expect(find.text("You're working locally on this computer"), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Create online account'), findsNWidgets(2),
          reason: 'one in the app bar and one in the banner');
    });

    testWidgets('hides signing in to another account while an import is pending', (tester) async {
      await pumpHome(tester);
      final db = appMode.database!;

      await db.update(db.importStates).write(ImportStatesCompanion(status: Value(ImportStatus.inProgress)));
      await appMode.refreshImportStatus();
      await tester.pumpAndSettle();

      expect(find.text(signInAction), findsNothing);
      expect(find.text(createAction), findsNothing, reason: 'the account already exists');
      expect(find.text('Finish moving your local data'), findsNWidgets(2),
          reason: 'app bar and banner');
    });

    testWidgets('"Create online account" opens registration, from the app bar and from the banner', (tester) async {
      for (final button in [
        find.descendant(of: find.byType(LocalModeBanner).hitTestable(), matching: find.text(createAction)),
        find.text(createAction).first,
      ]) {
        await pumpHome(tester);

        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.text('REGISTRATION SCREEN'), findsOneWidget);
      }
    });

    testWidgets('Settings opens the settings screen', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS SCREEN'), findsOneWidget);
    });
  });

  group('signing in to an existing account', () {
    setUp(() => addAccount('Main'));

    testWidgets('asks first, and says the local data stays where it is', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text(signInAction));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining("won't be moved to that account"), findsOneWidget);
      expect(find.textContaining('Use without an account'), findsOneWidget,
          reason: 'it says how to come back');
    });

    testWidgets('Cancel changes nothing', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text(signInAction));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNotNull);
      expect(find.text('LOGIN SCREEN'), findsNothing);
    });

    testWidgets('confirming leaves local mode, opens the login and keeps the app usable', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text(signInAction));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(appMode.isLocal, isFalse);
      expect(appMode.database, isNull);
      expect(find.text('LOGIN SCREEN'), findsOneWidget);
      expect((await SharedPreferences.getInstance()).getString('appMode'), 'online');
    });
  });

  group('a first-time local user', () {
    testWidgets('sees where the data lives and one obvious step', (tester) async {
      await pumpHome(tester);

      expect(find.text('Your data is stored encrypted on this computer only.'), findsOneWidget);
      expect(find.text('Create your first account'), findsOneWidget);
      expect(find.byType(AccountListDesktopView), findsNothing);
    });

    testWidgets('the step opens the account sheet, and the list takes over once there is an account', (tester) async {
      // The test font is much wider than a real one, and the sheet is capped at
      // 1200 px, so shrink the text to keep its row from overflowing.
      tester.platformDispatcher.textScaleFactorTestValue = 0.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpHome(tester);

      await tester.tap(find.text('Create your first account'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountSheetDesktop), findsOneWidget);

      await addAccount('Wallet');
      await tester.pumpAndSettle();

      expect(find.text('Create your first account'), findsNothing);
      expect(find.byType(AccountListDesktopView), findsOneWidget);
    });

    testWidgets('does not show the welcome when every account is hidden', (tester) async {
      await addAccount('Quiet');
      final quiet = accounts.getAllAccounts().single;
      await accounts.hide(quiet);

      await pumpHome(tester);

      expect(find.text('Create your first account'), findsNothing);
    });
  });
}
