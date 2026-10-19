import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_transaction.service.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/add_category_sheet.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/categories_list_widget.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/edit_category_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

class _UnreachableCategories implements CategoryDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Local mode reached the server: ${invocation.memberName}');
}

void main() {
  late AppModeService appMode;
  late CategoryRepository categories;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();
    categories = CategoryRepository(
        ModeAwareCategoryDataSource(_UnreachableCategories(), appMode));
    GetIt.I.registerSingleton(NotifierService());
    GetIt.I.registerSingleton(categories);
    await categories.load();
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
      home: const Scaffold(body: CategoriesListWidget()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> openRowMenu(WidgetTester tester, String categoryName, String item) async {
    final row = find.ancestor(of: find.text(categoryName), matching: find.byType(Card)).first;
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  Finder sheetField(Type sheet) =>
      find.descendant(of: find.byType(sheet), matching: find.byType(TextField));

  const taken = 'A category with this name already exists.';

  testWidgets('adding a name that is taken ignoring case shows an error and keeps the sheet open', (tester) async {
    await pumpList(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(sheetField(AddCategorySheet), 'rent');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text(taken), findsOneWidget);
    expect(find.byType(AddCategorySheet), findsOneWidget);
    expect(categories.categories, hasLength(17));

    await tester.enterText(sheetField(AddCategorySheet), 'Pets');
    await tester.pump();
    expect(find.text(taken), findsNothing, reason: 'the error clears when typing');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(AddCategorySheet), findsNothing);
    final pets = categories.categories.firstWhere((c) => c.name == 'Pets');
    expect(pets.isActive, isTrue, reason: 'it must be offered when adding a transaction');
    expect(categories.getActiveCategories().map((c) => c.name), contains('Pets'));
  });

  testWidgets('renaming to a taken name shows an error, keeps what was typed and the old name', (tester) async {
    await pumpList(tester);
    await openRowMenu(tester, 'Rent', 'Edit');

    await tester.enterText(sheetField(EditCategorySheet), 'GIFT');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(find.text(taken), findsOneWidget);
    expect(find.byType(EditCategorySheet), findsOneWidget);
    expect(tester.widget<TextField>(sheetField(EditCategorySheet)).controller!.text, 'GIFT');
    expect(categories.categories.map((c) => c.name), contains('Rent'));
    expect(categories.categories.map((c) => c.name), isNot(contains('GIFT')));
  });

  testWidgets('renaming to a free name saves it', (tester) async {
    await pumpList(tester);
    await openRowMenu(tester, 'Rent', 'Edit');

    await tester.enterText(sheetField(EditCategorySheet), 'Housing');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(find.byType(EditCategorySheet), findsNothing);
    expect(categories.categories.map((c) => c.name), contains('Housing'));
    expect(categories.categories.map((c) => c.name), isNot(contains('Rent')));
  });

  testWidgets('an unused category is deleted without a prompt', (tester) async {
    await pumpList(tester);

    await openRowMenu(tester, 'Rent', 'Delete');

    expect(find.byType(AlertDialog), findsNothing);
    expect(categories.categories.map((c) => c.name), isNot(contains('Rent')));
  });

  group('a category used by a transaction', () {
    setUp(() async {
      final db = appMode.database!;
      final accountId = await db.into(db.accounts).insert(
          AccountsCompanion.insert(name: 'Main', accountType: 0, currencyId: 1));
      final usedCategory = categories.categories.firstWhere((c) => c.name == 'Rent');
      await LocalTransactionService(db).add(TransactionModel(
          0, accountId, usedCategory.id, 'July rent', 500, DateTime(2026, 7, 1),
          TransactionType.Outcome));
    });

    testWidgets('cannot be deleted, and Cancel changes nothing', (tester) async {
      await pumpList(tester);

      await openRowMenu(tester, 'Rent', 'Delete');
      expect(find.textContaining("can't be deleted"), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final rent = categories.categories.firstWhere((c) => c.name == 'Rent');
      expect(rent.isActive, isTrue);
      expect(categories.categories, hasLength(17));
    });

    testWidgets('can be deactivated instead', (tester) async {
      await pumpList(tester);

      await openRowMenu(tester, 'Rent', 'Delete');
      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      final rent = categories.categories.firstWhere((c) => c.name == 'Rent');
      expect(rent.isActive, isFalse);
      expect(categories.getActiveCategories().map((c) => c.name), isNot(contains('Rent')));
      expect(categories.categories, hasLength(17), reason: 'it is kept, with its history');
    });
  });
}
