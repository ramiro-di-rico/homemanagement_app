import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/mode_aware_data_sources.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/categories_list_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';
import '../helpers/storage_failures.dart';

class _Remote implements CategoryDataSource {
  final List<String> calls = [];
  final List<CategoryModel> data = [
    CategoryModel(1, 1, 'Rent', 'home', true, true, '#ffffff'),
  ];

  @override
  Future<List<CategoryModel>> fetch() async => List.of(data);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls.add(invocation.memberName.toString());
    return Future.value();
  }
}

/// The Active checkbox on the categories list (RF-15). A deactivated category keeps
/// its history and can be switched back on.
void main() {
  late AppModeService appMode;
  late CategoryRepository categories;

  Future<void> setUpLocal() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async =>
            LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();
    final notifier = NotifierService();
    categories = CategoryRepository(
        ModeAwareCategoryDataSource(_Remote(), appMode),
        notifierService: notifier);
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton(notifier)
      ..registerSingleton(categories);
    await categories.load();
  }

  tearDown(() async {
    await appMode.database?.close();
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

  Finder row(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(Card)).first;

  /// The first checkbox of a row is Active, the second Measurable.
  Finder activeBox(String name) =>
      find.descendant(of: row(name), matching: find.byType(Checkbox)).first;

  bool isChecked(WidgetTester tester, String name) =>
      tester.widget<Checkbox>(activeBox(name)).value!;

  CategoryModel stored(String name) =>
      categories.categories.firstWhere((c) => c.name == name);

  group('in local mode', () {
    setUp(setUpLocal);

    testWidgets('unticking deactivates the category, and ticking brings it back', (tester) async {
      await pumpList(tester);
      expect(isChecked(tester, 'Rent'), isTrue);

      await tester.tap(activeBox('Rent'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Rent'), isFalse);
      expect(stored('Rent').isActive, isFalse);
      expect(categories.getActiveCategories().map((c) => c.name), isNot(contains('Rent')));
      expect(CategoryRepository.selectable(categories.categories, onlyActive: true).map((c) => c.name),
          isNot(contains('Rent')));

      await tester.tap(activeBox('Rent'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Rent'), isTrue);
      expect(categories.getActiveCategories().map((c) => c.name), contains('Rent'));
    });

    testWidgets('it is saved, so it survives reloading the list', (tester) async {
      await pumpList(tester);

      await tester.tap(activeBox('Gift'));
      await tester.pumpAndSettle();
      await categories.load();
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Gift'), isFalse);
      expect(categories.categories.where((c) => !c.isActive).map((c) => c.name), ['Gift']);
    });

    testWidgets('only that category changes, not its other settings', (tester) async {
      await pumpList(tester);
      final before = stored('Rent');

      await tester.tap(activeBox('Rent'));
      await tester.pumpAndSettle();

      final after = stored('Rent');
      expect([after.name, after.icon, after.color, after.measurable],
          [before.name, before.icon, before.color, before.measurable]);
      expect(categories.categories.where((c) => !c.isActive), hasLength(1));
    });

    testWidgets('a category in use is offered "Deactivate", and that really deactivates it', (tester) async {
      final db = appMode.database!;
      final account = await db.into(db.accounts).insert(
          AccountsCompanion.insert(name: 'Main', accountType: 0, currencyId: 1));
      await db.into(db.transactions).insert(TransactionsCompanion.insert(
          accountId: account,
          categoryId: stored('Rent').id,
          name: 'July',
          amount: 10,
          transactionType: 1,
          date: DateTime.utc(2026, 7, 1),
          createdAt: DateTime.utc(2026, 7, 1)));
      await pumpList(tester);

      await tester.tap(find.descendant(of: row('Rent'), matching: find.byIcon(Icons.more_vert)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.textContaining("can't be deleted"), findsOneWidget);
      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Rent'), isFalse, reason: 'still listed, now off');
      expect(stored('Rent').isActive, isFalse);
    });

    testWidgets('a save that fails leaves it ticked and says so', (tester) async {
      await pumpList(tester);
      await makeStorageReadOnly(appMode.database!);

      await tester.tap(activeBox('Rent'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Rent'), isTrue);
      expect(stored('Rent').isActive, isTrue);
      expect(find.text("Your change couldn't be saved. Nothing was changed."), findsOneWidget);
    });

    testWidgets('while a move to the online account is pending it is refused, with the reason',
        (tester) async {
      await pumpList(tester);
      final db = appMode.database!;
      await db.update(db.importStates).write(
          const ImportStatesCompanion(status: Value(ImportStatus.inProgress)));
      await appMode.refreshImportStatus();

      await tester.tap(activeBox('Rent'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Rent'), isTrue);
      expect(find.textContaining('is being moved to your online account'), findsOneWidget);
    });
  });

  testWidgets('online, the checkbox is unchanged: it does nothing and calls no server', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop));
    await appMode.init();
    final remote = _Remote();
    final notifier = NotifierService();
    categories = CategoryRepository(ModeAwareCategoryDataSource(remote, appMode),
        notifierService: notifier);
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton(notifier)
      ..registerSingleton(categories);
    await categories.load();
    await pumpList(tester);

    await tester.tap(activeBox('Rent'));
    await tester.pumpAndSettle();

    expect(isChecked(tester, 'Rent'), isTrue);
    expect(remote.calls, isEmpty);
  });

  group('which categories a picker offers', () {
    final all = [
      CategoryModel(1, 0, 'A', 'x', true, true, '#fff'),
      CategoryModel(2, 0, 'B', 'x', true, false, '#fff'),
      CategoryModel(3, 0, 'C', 'x', true, true, '#fff'),
    ];
    List<String> names(List<CategoryModel> l) => l.map((c) => c.name).toList();

    test('everything when not filtering, as online', () {
      expect(names(CategoryRepository.selectable(all, onlyActive: false)), ['A', 'B', 'C']);
    });

    test('only the active ones when filtering', () {
      expect(names(CategoryRepository.selectable(all, onlyActive: true)), ['A', 'C']);
    });

    test('plus the one an existing transaction already has', () {
      expect(names(CategoryRepository.selectable(all, onlyActive: true, keep: 2)), ['A', 'B', 'C']);
    });

    test('a kept category that is active is not listed twice', () {
      expect(names(CategoryRepository.selectable(all, onlyActive: true, keep: 1)), ['A', 'C']);
    });

    test('never empty: with everything off, everything is offered', () {
      final off = [for (final c in all) CategoryModel(c.id, 0, c.name, 'x', true, false, '#fff')];
      expect(names(CategoryRepository.selectable(off, onlyActive: true)), ['A', 'B', 'C']);
    });
  });
}
