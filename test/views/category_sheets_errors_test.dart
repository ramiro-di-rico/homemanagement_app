import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/add_category_sheet.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/categories_list_widget.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/edit_category_sheet.dart';

/// A data source the test can make slow or failing, the way a request to the
/// server is: it throws a plain `Exception`, with no status or body.
class _Categories implements CategoryDataSource {
  final List<CategoryModel> data = [
    CategoryModel(1, 1, 'Gym', 'home', true, true, '#00ff00'),
    CategoryModel(2, 1, 'Rent', 'home', true, true, '#ff0000'),
  ];
  Object? failWith;
  Completer<void>? gate;
  int adds = 0, updates = 0;

  CategoryModel _copy(CategoryModel c) =>
      CategoryModel(c.id, c.userId, c.name, c.icon, c.measurable, c.isActive, c.color);

  @override
  Future<List<CategoryModel>> fetch() async => [for (final c in data) _copy(c)];

  @override
  Future<CategoryModel> add(CategoryModel category) async {
    adds++;
    await gate?.future;
    if (failWith != null) throw failWith!;
    final created = CategoryModel(100 + adds, 1, category.name, 'empty', false, false, '#ffffff');
    data.add(created);
    return _copy(created);
  }

  @override
  Future update(CategoryModel category) async {
    updates++;
    await gate?.future;
    if (failWith != null) throw failWith!;
    final i = data.indexWhere((c) => c.id == category.id);
    data[i] = _copy(category);
  }

  @override
  Future delete(CategoryModel category) async => data.removeWhere((c) => c.id == category.id);
}

void main() {
  const notSaved = "Your change couldn't be saved. Nothing was changed.";
  late _Categories source;
  late CategoryRepository categories;

  setUp(() async {
    await GetIt.I.reset();
    source = _Categories();
    final notifier = NotifierService();
    categories = CategoryRepository(source, notifierService: notifier);
    GetIt.I
      ..registerSingleton(notifier)
      ..registerSingleton(categories);
    await categories.load();
  });

  tearDown(() => GetIt.I.reset());

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

  Finder sheetField(Type sheet) =>
      find.descendant(of: find.byType(sheet), matching: find.byType(TextField));

  Finder button(String label) => find.widgetWithText(ElevatedButton, label);

  Future<void> openAdd(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }

  Future<void> openEdit(WidgetTester tester, String name) async {
    final row = find.ancestor(of: find.text(name), matching: find.byType(Card)).first;
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  CategoryModel stored(String name) => categories.categories.firstWhere((c) => c.name == name);

  group('adding', () {
    testWidgets('a double click sends the category once, and the button is off meanwhile',
        (tester) async {
      source.gate = Completer<void>();
      await pumpList(tester);
      await openAdd(tester);
      await tester.enterText(sheetField(AddCategorySheet), 'Pets');

      await tester.tap(button('Add'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button('Add')).onPressed, isNull,
          reason: 'saving: nothing more to click');
      await tester.tap(button('Add'), warnIfMissed: false);
      await tester.pump();

      source.gate!.complete();
      await tester.pumpAndSettle();

      expect(source.adds, 1);
      expect(find.byType(AddCategorySheet), findsNothing);
      expect(categories.categories.where((c) => c.name == 'Pets'), hasLength(1));
    });

    testWidgets('a failed request keeps the sheet and the typed name, says so, and can be retried',
        (tester) async {
      source.failWith = Exception('connection lost');
      await pumpList(tester);
      await openAdd(tester);
      await tester.enterText(sheetField(AddCategorySheet), 'Pets');

      await tester.tap(button('Add'));
      await tester.pumpAndSettle();

      expect(find.byType(AddCategorySheet), findsOneWidget);
      expect(tester.widget<TextField>(sheetField(AddCategorySheet)).controller!.text, 'Pets');
      expect(find.text(notSaved), findsOneWidget);
      expect(categories.categories.map((c) => c.name), ['Gym', 'Rent']);
      expect(tester.widget<ElevatedButton>(button('Add')).onPressed, isNotNull,
          reason: 'it can be tried again');

      source.failWith = null;
      await tester.tap(button('Add'));
      await tester.pumpAndSettle();

      expect(find.byType(AddCategorySheet), findsNothing);
      expect(categories.categories.map((c) => c.name), ['Gym', 'Pets', 'Rent']);
    });
  });

  group('editing', () {
    testWidgets('a failed request leaves the list showing what is stored', (tester) async {
      await pumpList(tester);
      await openEdit(tester, 'Rent');
      await tester.enterText(sheetField(EditCategorySheet), 'Rental');
      source.failWith = Exception('connection lost');

      await tester.tap(button('Update'));
      await tester.pumpAndSettle();

      expect(find.byType(EditCategorySheet), findsOneWidget);
      expect(tester.widget<TextField>(sheetField(EditCategorySheet)).controller!.text, 'Rental',
          reason: 'what was typed is kept');
      expect(find.text(notSaved), findsOneWidget);
      // The list still shows the stored category, not a name that was never saved.
      expect(stored('Rent').color, '#ff0000');
      expect(categories.categories.map((c) => c.name), ['Gym', 'Rent']);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('and the retry saves it, in its place in the order', (tester) async {
      await pumpList(tester);
      await openEdit(tester, 'Rent');
      await tester.enterText(sheetField(EditCategorySheet), 'Zebra');
      source.failWith = Exception('connection lost');
      await tester.tap(button('Update'));
      await tester.pumpAndSettle();

      source.failWith = null;
      await tester.tap(button('Update'));
      await tester.pumpAndSettle();

      expect(find.byType(EditCategorySheet), findsNothing);
      expect(categories.categories.map((c) => c.name), ['Gym', 'Zebra']);
      expect(source.data.map((c) => c.name), contains('Zebra'));
    });

    testWidgets('a double click sends the change once', (tester) async {
      await pumpList(tester);
      await openEdit(tester, 'Rent');
      await tester.enterText(sheetField(EditCategorySheet), 'Rental');
      source.gate = Completer<void>();

      await tester.tap(button('Update'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(button('Update')).onPressed, isNull);
      await tester.tap(button('Update'), warnIfMissed: false);
      await tester.pump();
      source.gate!.complete();
      await tester.pumpAndSettle();

      expect(source.updates, 1);
      expect(find.byType(EditCategorySheet), findsNothing);
    });

    testWidgets('a name that is taken shows the error and leaves the list alone', (tester) async {
      await pumpList(tester);
      await openEdit(tester, 'Rent');
      await tester.enterText(sheetField(EditCategorySheet), 'Gym');
      source.failWith = CategoryNameTakenException();

      await tester.tap(button('Update'));
      await tester.pumpAndSettle();

      expect(find.text('A category with this name already exists.'), findsOneWidget);
      expect(categories.categories.map((c) => c.name), ['Gym', 'Rent']);
      expect(tester.widget<ElevatedButton>(button('Update')).onPressed, isNotNull);
    });
  });

  test('the repository shows what was saved, wherever it sorts', () async {
    final renamed = CategoryModel(2, 1, 'Zebra', 'home', true, true, '#123456');

    await categories.update(renamed);

    expect(categories.categories.map((c) => c.name), ['Gym', 'Zebra']);
    expect(identical(stored('Zebra'), renamed), isTrue);
  });
}
