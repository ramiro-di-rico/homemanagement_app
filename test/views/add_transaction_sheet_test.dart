import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/custom/components/app-textfield.dart';
import 'package:home_management_app/ui/features/accounts/views/widgets/add.transaction.sheet.dart';

class FakeCategoryRepository extends ChangeNotifier implements CategoryRepository {
  @override
  final List<CategoryModel> categories;

  FakeCategoryRepository(this.categories);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTransactionRepository extends ChangeNotifier implements TransactionRepository {
  final List<TransactionModel> suggestionsToReturn;
  TransactionModel? addedTransaction;
  TransactionModel? updatedTransaction;

  FakeTransactionRepository({this.suggestionsToReturn = const []});

  @override
  Future<List<TransactionModel>> getSuggestions({bool forceRefresh = false}) async {
    return suggestionsToReturn;
  }

  @override
  Future add(TransactionModel transactionModel) async {
    addedTransaction = transactionModel;
  }

  @override
  Future update(TransactionModel transactionModel) async {
    updatedTransaction = transactionModel;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAccountRepository extends ChangeNotifier implements AccountRepository {
  @override
  final List<AccountModel> accounts;

  FakeAccountRepository(this.accounts);

  @override
  Future load() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testAccount = AccountModel(
    1,
    'Main Checking',
    1000.0,
    true,
    AccountType.BankAccount,
    1,
    1,
    false,
    false,
  );

  final otherAccount = AccountModel(
    2,
    'Savings Vault',
    5000.0,
    true,
    AccountType.BankAccount,
    1,
    1,
    false,
    false,
  );

  final testCategories = [
    CategoryModel(1, 1, 'General', 'icon', true, true, '#ffffff'),
    CategoryModel(2, 1, 'Transfer', 'icon', true, true, '#ffffff'),
  ];

  final testSuggestions = [
    TransactionModel(
      101,
      1,
      1,
      'Supermarket Groceries',
      45.50,
      DateTime(2026, 1, 1),
      TransactionType.Outcome,
      categoryName: 'General',
    ),
  ];

  Future<void> pumpMobileSheet(
    WidgetTester tester, {
    required FakeCategoryRepository categoryRepo,
    required FakeTransactionRepository transactionRepo,
    required FakeAccountRepository accountRepo,
    TransactionModel? transactionModel,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            viewInsets: viewInsets,
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (context) => AddTransactionSheet(
                      testAccount,
                      transactionModel: transactionModel,
                      categoryRepository: categoryRepo,
                      transactionRepository: transactionRepo,
                      accountRepository: accountRepo,
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens sheet within 85% height limit and adapts to keyboard insets', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount]);

    await pumpMobileSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
      viewInsets: EdgeInsets.zero,
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final sheetFinder = find.byType(AddTransactionSheet);
    expect(sheetFinder, findsOneWidget);

    final initialSize = tester.getSize(sheetFinder);
    expect(initialSize.height, lessThanOrEqualTo(800 * 0.85));

    // Dismiss the first sheet by tapping modal barrier
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionSheet), findsNothing);

    // Re-verify modal bottom sheet with keyboard insets
    await pumpMobileSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
      viewInsets: const EdgeInsets.only(bottom: 300),
    );
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final withKeyboardSize = tester.getSize(find.byType(AddTransactionSheet));
    expect(withKeyboardSize.height, lessThanOrEqualTo(800 * 0.85));
  });

  testWidgets('shows suggestions in mobile sheet and populates transaction name', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount]);

    await pumpMobileSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final nameField = find.byType(AppTextField);
    expect(nameField, findsOneWidget);

    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'Super');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Supermarket Groceries'), findsOneWidget);
    await tester.tap(find.text('Supermarket Groceries'));
    await tester.pumpAndSettle();

    final appTextField = tester.widget<AppTextField>(nameField);
    expect(appTextField.controller.text, 'Supermarket Groceries');
  });

  testWidgets('editing existing transaction pre-fills data and calls update on submit', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount]);

    final existingTransaction = TransactionModel(
      55,
      testAccount.id,
      1,
      'Coffee',
      4.50,
      DateTime(2026, 1, 1),
      TransactionType.Outcome,
      categoryName: 'General',
    );

    await pumpMobileSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
      transactionModel: existingTransaction,
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    final nameField = find.byType(AppTextField);
    final appTextField = tester.widget<AppTextField>(nameField);
    expect(appTextField.controller.text, 'Coffee');

    // Tap the submit check icon
    final checkButton = find.byIcon(Icons.check);
    expect(checkButton, findsOneWidget);
    await tester.tap(checkButton);
    await tester.pumpAndSettle();

    expect(transactionRepo.updatedTransaction, isNotNull);
    expect(transactionRepo.updatedTransaction?.name, 'Coffee');
    expect(find.byType(AddTransactionSheet), findsNothing);
  });
}
