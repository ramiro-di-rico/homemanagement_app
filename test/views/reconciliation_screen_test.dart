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
  List<ReconciliationReferenceLink> lastReferencesToLink = [];
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
    lastReferencesToLink = referencesToLink ?? const [];
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
    // Singular: the message used to read "1 transactions".
    expect(find.text('1 transaction will be deleted permanently.'),
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

  testWidgets('the delete confirmation counts in plural too', (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWith(extraCount: 2));
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Not in statement (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply (3)'));
    await tester.pumpAndSettle();

    expect(find.text('2 transactions will be deleted permanently.'),
        findsOneWidget);
  });

  testWidgets('an extra near the period edge is flagged before deleting',
      (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWith(nearPeriodEdge: true));
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Not in statement (1)'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Could belong to a neighbouring statement'),
        findsOneWidget);
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

  testWidgets('the balance message names the date it refers to',
      (tester) async {
    final controller = FakeReconciliationController(preview: previewWith())
      ..applyResult = ApplyReconciliationResultModel(
        createdCount: 1,
        deletedCount: 0,
        linkedCount: 0,
        balanceCheck: BalanceCheckModel(
          expected: 100,
          actual: 120,
          difference: 20,
          matches: false,
          asOf: DateTime.utc(2026, 7, 31),
        ),
      );
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Apply (1)'));
    await tester.pumpAndSettle();

    // Without the date, a difference against a past statement means nothing.
    expect(find.textContaining('Difference against the statement at Jul 31, 2026'),
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

  testWidgets('a possible match is only a suggestion until it is linked',
      (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWithPossibleMatch());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Possible matches (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Link'), findsOneWidget);
    expect(find.text('3,000 apart · 1 day apart'), findsOneWidget);
    // Nothing changed: the row is still going to be created.
    expect(find.text('Apply (1)'), findsOneWidget);
  });

  testWidgets('linking a possible match links it instead of creating the row',
      (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWithPossibleMatch());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Possible matches (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply (1)'));
    await tester.pumpAndSettle();

    expect(controller.lastCreated, isEmpty);
    expect(controller.lastDeleted, isEmpty);
    final link = controller.lastReferencesToLink.single;
    expect(link.transactionId, 99);
    expect(link.externalReference, '111');
  });

  testWidgets('a linked row is no longer offered for creation', (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWithPossibleMatch());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Possible matches (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();

    // The tab bar scrolled while reaching the possible matches, so the first tab has to be brought
    // back into view before it can be tapped.
    final missingTab = find.text('Missing (1)');
    await tester.ensureVisible(missingTab);
    await tester.pumpAndSettle();
    await tester.tap(missingTab);
    await tester.pumpAndSettle();

    // No checkbox at all: linking already accounts for the movement.
    expect(checkboxValues(tester), isEmpty);
    expect(find.textContaining('Will be linked to Playroom 1'), findsOneWidget);
  });

  testWidgets('a linked transaction is no longer offered for deletion',
      (tester) async {
    final controller =
        FakeReconciliationController(preview: previewWithPossibleMatch());
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Possible matches (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not in statement (1)'));
    await tester.pumpAndSettle();

    expect(checkboxValues(tester), isEmpty);
    expect(find.textContaining('Will be linked to Pago con QR PLAYROOM'),
        findsOneWidget);
  });

  testWidgets('a row links to one transaction only', (tester) async {
    // Two candidates for the same row: confirming the second replaces the first.
    final controller = FakeReconciliationController(
        preview: previewWithPossibleMatch(extraCount: 2));
    await pumpScreen(tester, controller);

    await tester.tap(find.text('Possible matches (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link').first);
    await tester.pumpAndSettle();

    // The other candidate is out of reach while this one holds the row.
    final other = tester.widget<TextButton>(find.byType(TextButton).last);
    expect(other.onPressed, isNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Link').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply (1)'));
    await tester.pumpAndSettle();

    expect(controller.lastReferencesToLink.single.transactionId, 100);
  });
}

List<bool?> checkboxValues(WidgetTester tester) => tester
    .widgetList<Checkbox>(find.byType(Checkbox))
    .map((c) => c.value)
    .toList();

/// One statement row and one transaction of the same merchant that do not match on their own: the
/// possible-match case, with both sides also reported as missing and extra.
ReconciliationPreviewModel previewWithPossibleMatch({int extraCount = 1}) =>
    ReconciliationPreviewModel.fromJson({
      'accountId': 3,
      'periodStart': '2026-07-01T00:00:00Z',
      'periodEnd': '2026-07-31T00:00:00Z',
      'matched': [],
      'missing': [
        {
          'row': _playroomRow,
          'suggestedCategoryId': 7,
        },
      ],
      'extra': List.generate(
          extraCount,
          (i) => {
                'transaction': _playroomTransaction(99 + i, i + 1),
                'nearPeriodEdge': false,
              }),
      'ambiguous': [],
      'possibleMatches': List.generate(
          extraCount,
          (i) => {
                'row': _playroomRow,
                'transaction': _playroomTransaction(99 + i, i + 1),
                'amountDifference': -3000.0,
                'dayDifference': 1,
              }),
    });

const _playroomRow = {
  'reference': '111',
  'name': 'Pago con QR PLAYROOM S. R. L.',
  'price': 13000.0,
  'date': '2026-07-16T00:00:00Z',
  'transactionType': 1,
};

Map<String, dynamic> _playroomTransaction(int id, int number) => {
      'id': id,
      'accountId': 3,
      'categoryId': 1,
      'name': 'Playroom $number',
      'price': 16000.0,
      'date': '2026-07-15T00:00:00Z',
      'transactionType': 1,
      'categoryName': 'Juegos',
      'tags': [],
    };

/// One missing row and one extra transaction, which is enough to exercise both selections.
ReconciliationPreviewModel previewWith(
        {int? suggestedCategoryId = 7,
        int accountId = 3,
        int extraCount = 1,
        bool nearPeriodEdge = false}) =>
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
      'extra': List.generate(
          extraCount,
          (i) => {
                'transaction': {
                  'id': 99 + i,
                  'accountId': 3,
                  'categoryId': 1,
                  'name': 'Duplicado ${i + 1}',
                  'price': 500.0,
                  'date': '2026-07-15T00:00:00Z',
                  'transactionType': 1,
                  'categoryName': 'Comida',
                  'tags': [],
                },
                'nearPeriodEdge': nearPeriodEdge,
              }),
      'ambiguous': [],
    });
