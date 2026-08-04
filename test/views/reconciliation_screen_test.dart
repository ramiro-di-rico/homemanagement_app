import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/models/reconciliation.dart';
import 'package:home_management_app/data/repositories/reconciliation_repository.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/transactions/views/reconciliation_screen.dart';

/// Records what the screen asks for instead of talking to the API.
class FakeReconciliationController extends ChangeNotifier
    implements ReconciliationController {
  FakeReconciliationController({ReconciliationPreviewModel? preview})
      : _preview = preview;

  ReconciliationPreviewModel? _preview;

  int applyCallCount = 0;
  List<ReconciliationTransactionToCreate> lastCreated = [];
  List<int> lastDeleted = [];
  ApplyReconciliationResultModel? applyResult;

  @override
  ReconciliationPreviewModel? get preview => _preview;

  @override
  bool get isLoading => false;

  @override
  bool get hasPreview => _preview != null;

  @override
  Future<ReconciliationPreviewModel?> loadPreview(
          int accountId, String fileContent,
          {StatementFormat format = StatementFormat.accountStatementCsv}) async =>
      _preview;

  @override
  Future<ApplyReconciliationResultModel?> apply(
    int accountId, {
    List<ReconciliationTransactionToCreate> transactionsToCreate = const [],
    List<int> transactionIdsToDelete = const [],
    List<ReconciliationReferenceLink>? referencesToLink,
    bool verifyBalance = true,
  }) async {
    applyCallCount++;
    lastCreated = transactionsToCreate;
    lastDeleted = transactionIdsToDelete;
    _preview = null;
    notifyListeners();
    return applyResult ??
        ApplyReconciliationResultModel(
            createdCount: transactionsToCreate.length,
            deletedCount: transactionIdsToDelete.length,
            linkedCount: 0);
  }

  @override
  List<ReconciliationReferenceLink> pendingReferenceLinks() => const [];

  @override
  void clear() {
    // No-op: the screen clears on init, and these cases are about a preview already loaded.
  }
}

void main() {
  final account = AccountModel(
      3, 'Cuenta banco', 1000, true, AccountType.BankAccount, 1, 1, false, false);
  final categories = [
    CategoryModel(7, 1, 'Comida', 'icon', true, true, '#ffffff'),
    CategoryModel(8, 1, 'Servicios', 'icon', true, true, '#ffffff'),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    FakeReconciliationController controller,
  ) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      // The ink ripple pulls in a shader the local engine build cannot decode.
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReconciliationScreen(account,
          controller: controller, categoriesProvider: () => categories),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('without a statement it invites picking a file', (tester) async {
    await pumpScreen(tester, FakeReconciliationController());

    expect(find.text('Select statement file'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('missing rows start selected and extra rows do not',
      (tester) async {
    final controller = FakeReconciliationController(preview: previewWith());
    await pumpScreen(tester, controller);

    // Missing tab is the first one: its row is checked.
    expect(checkboxValues(tester), [true]);

    await tester.tap(find.text('Not in statement (1)'));
    await tester.pumpAndSettle();

    // Deleting is destructive, so nothing is preselected here.
    expect(checkboxValues(tester), [false]);
  });

  testWidgets('applying only creates the selected missing rows', (tester) async {
    final controller = FakeReconciliationController(preview: previewWith());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Apply (1)'));
    await tester.pumpAndSettle();

    expect(controller.applyCallCount, 1);
    expect(controller.lastCreated.single.externalReference, '222');
    expect(controller.lastCreated.single.categoryId, 7);
    expect(controller.lastDeleted, isEmpty);
  });

  testWidgets('a missing row without a suggested category blocks applying',
      (tester) async {
    final controller = FakeReconciliationController(
        preview: previewWith(suggestedCategoryId: null));
    await pumpScreen(tester, controller);

    expect(find.text('Pick a category for every movement to create'),
        findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('deleting asks for confirmation and cancelling applies nothing',
      (tester) async {
    final controller = FakeReconciliationController(preview: previewWith());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Not in statement (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Delete transactions?'), findsOneWidget);
    expect(find.text('1 transactions will be deleted permanently.'),
        findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(controller.applyCallCount, 0);
  });

  testWidgets('confirming the deletion applies it', (tester) async {
    final controller = FakeReconciliationController(preview: previewWith());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Not in statement (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(controller.applyCallCount, 1);
    expect(controller.lastDeleted, [99]);
    expect(find.textContaining('created'), findsOneWidget);
  });

  testWidgets('a balance difference is reported after applying', (tester) async {
    final controller = FakeReconciliationController(preview: previewWith())
      ..applyResult = ApplyReconciliationResultModel(
        createdCount: 1,
        deletedCount: 0,
        linkedCount: 0,
        balanceCheck: BalanceCheckModel(
            expected: 100, actual: 120, difference: 20, matches: false),
      );
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Apply (1)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Difference against the statement'),
        findsOneWidget);
  });

  testWidgets('a preview of another account is not shown', (tester) async {
    final controller = FakeReconciliationController(preview: previewWith(accountId: 44));
    await pumpScreen(tester, controller);

    // Applying it here would create another account's movements on this one.
    expect(find.text('Select statement file'), findsOneWidget);
    expect(find.textContaining('Apply'), findsNothing);
  });

  testWidgets('a statement with nothing pending says so', (tester) async {
    final controller = FakeReconciliationController(
        preview: ReconciliationPreviewModel.fromJson({
      'accountId': 3,
      'periodStart': '2026-07-01T00:00:00Z',
      'periodEnd': '2026-07-31T00:00:00Z',
      'matched': [],
      'missing': [],
      'extra': [],
      'ambiguous': [],
    }));
    await pumpScreen(tester, controller);

    expect(find.text('This statement is fully reconciled'), findsOneWidget);
  });
}

List<bool?> checkboxValues(WidgetTester tester) => tester
    .widgetList<Checkbox>(find.byType(Checkbox))
    .map((c) => c.value)
    .toList();

/// One missing row and one extra transaction, which is enough to exercise both selections.
ReconciliationPreviewModel previewWith(
        {int? suggestedCategoryId = 7, int accountId = 3}) =>
    ReconciliationPreviewModel.fromJson({
      'accountId': accountId,
      'periodStart': '2026-07-01T00:00:00Z',
      'periodEnd': '2026-07-31T00:00:00Z',
      'statementBalances': {
        'initialBalance': 0.0,
        'credits': 0.0,
        'debits': 0.0,
        'finalBalance': 100.0,
      },
      'matched': [],
      'missing': [
        {
          'row': {
            'reference': '222',
            'name': 'Pago Sushimei',
            'price': 9000.0,
            'date': '2026-07-16T00:00:00Z',
            'transactionType': 1,
          },
          'suggestedCategoryId': suggestedCategoryId,
        },
      ],
      'extra': [
        {
          'id': 99,
          'accountId': 3,
          'categoryId': 1,
          'name': 'Duplicado',
          'price': 500.0,
          'date': '2026-07-15T00:00:00Z',
          'transactionType': 1,
          'categoryName': 'Comida',
          'tags': [],
        },
      ],
      'ambiguous': [],
    });
