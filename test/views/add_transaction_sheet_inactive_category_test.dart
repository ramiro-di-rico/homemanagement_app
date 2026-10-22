import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/custom/components/app-textfield.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';
import 'add_transaction_sheet_desktop_test.dart'
    show FakeAccountRepository, FakeCategoryRepository, FakeTransactionRepository;

/// A deactivated category is no longer offered when adding a transaction in local
/// mode (RF-15). Online it still is, because the server creates every category
/// inactive and the pickers never filtered on it.
void main() {
  final account = AccountModel(1, 'Main', 100, true, AccountType.Cash, 1, 1, false, false);
  final categories = [
    CategoryModel(1, 1, 'General', 'icon', true, true, '#ffffff'),
    CategoryModel(2, 1, 'Archived', 'icon', true, false, '#ffffff'),
    CategoryModel(3, 1, 'Pets', 'icon', true, true, '#ffffff'),
  ];
  late AppModeService appMode;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async =>
            LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
  });

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<void> pump(
    WidgetTester tester, {
    required bool local,
    List<CategoryModel>? all,
    TransactionModel? editing,
    List<TransactionModel> suggestions = const [],
  }) async {
    if (local) await appMode.enterLocalMode();
    GetIt.I.registerSingleton<AppModeService>(appMode);
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: AddTransactionSheetDesktop(
            account,
            transactionModel: editing,
            categoryRepository: FakeCategoryRepository(all ?? categories),
            transactionRepository: FakeTransactionRepository(suggestionsToReturn: suggestions),
            accountRepository: FakeAccountRepository([account]),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// The names offered by the category dropdown.
  Future<Set<String>> offered(WidgetTester tester, String current) async {
    await tester.tap(find.text(current));
    await tester.pumpAndSettle();
    final names = {
      for (final name in ['General', 'Archived', 'Pets'])
        if (find.text(name).evaluate().length > (name == current ? 1 : 0)) name,
    };
    // Close the menu again.
    await tester.tap(find.text(current).last);
    await tester.pumpAndSettle();
    return names;
  }

  testWidgets('local: a deactivated category is not offered', (tester) async {
    await pump(tester, local: true);

    expect(await offered(tester, 'General'), {'General', 'Pets'});
  });

  testWidgets('online: every category is still offered', (tester) async {
    await pump(tester, local: false);

    expect(await offered(tester, 'General'), {'General', 'Archived', 'Pets'});
  });

  testWidgets('local: editing a transaction keeps the category it already has, even if it was deactivated',
      (tester) async {
    final existing = TransactionModel(
        7, 1, 2, 'Old rent', 50, DateTime(2026, 1, 1), TransactionType.Outcome,
        categoryName: 'Archived');

    await pump(tester, local: true, editing: existing);

    expect(find.text('Archived'), findsOneWidget, reason: 'still shown as the current category');
    expect(await offered(tester, 'Archived'), {'General', 'Archived', 'Pets'});
  });

  testWidgets('local: a new transaction starts on the first active category, not the first one',
      (tester) async {
    await pump(tester, local: true, all: [
      CategoryModel(9, 1, 'Archived', 'icon', true, false, '#ffffff'),
      ...categories.where((c) => c.id != 2),
    ]);

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('local: choosing a past transaction whose category was deactivated keeps the current one',
      (tester) async {
    final past = TransactionModel(
        101, 1, 2, 'Savings Transfer', 100, DateTime(2026, 1, 1), TransactionType.Outcome,
        categoryName: 'Archived');
    await pump(tester, local: true, suggestions: [past]);

    final nameField = find.byType(AppTextField);
    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'Sav');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Savings Transfer'));
    await tester.pumpAndSettle();

    expect(tester.widget<AppTextField>(nameField).controller.text, 'Savings Transfer');
    expect(find.text('General'), findsOneWidget, reason: 'the name was filled in, the category was not');
    expect(find.text('Archived'), findsNothing);
  });

  testWidgets('local: switching every category off still leaves something to choose', (tester) async {
    await pump(tester, local: true, all: [
      CategoryModel(1, 1, 'General', 'icon', true, false, '#ffffff'),
      CategoryModel(3, 1, 'Pets', 'icon', true, false, '#ffffff'),
    ]);

    expect(find.text('General'), findsOneWidget);
  });
}
