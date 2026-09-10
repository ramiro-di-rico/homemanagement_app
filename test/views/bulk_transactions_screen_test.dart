import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/core/screens/bulk_transactions_screen.dart';

class FakeCategoryRepository extends ChangeNotifier implements CategoryRepository {
  @override
  final List<CategoryModel> categories;

  FakeCategoryRepository(this.categories);

  @override
  List<CategoryModel> getActiveCategories() =>
      categories.where((c) => c.isActive).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTransactionRepository extends ChangeNotifier implements TransactionRepository {
  final List<TransactionModel> suggestionsToReturn;

  FakeTransactionRepository({this.suggestionsToReturn = const []});

  @override
  Future<List<TransactionModel>> getSuggestions({bool forceRefresh = false}) async {
    return suggestionsToReturn;
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

class FakeTransactionService implements TransactionService {
  List<TransactionModel>? bulkAddedTransactions;

  @override
  Future<List<AccountModel>> bulkAdd(List<TransactionModel> transactions) async {
    bulkAddedTransactions = transactions;
    return [];
  }

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

  final cashAccount = AccountModel(
    3,
    'Wallet Cash',
    200.0,
    true,
    AccountType.Cash,
    1,
    1,
    false,
    false,
  );

  final testCategories = [
    CategoryModel(1, 1, 'General', 'icon', true, true, '#ffffff'),
    CategoryModel(2, 1, 'Groceries', 'icon', true, true, '#ffffff'),
  ];

  final testSuggestions = [
    TransactionModel(
      101,
      2,
      2,
      'Supermarket Groceries',
      45.50,
      DateTime(2026, 1, 1),
      TransactionType.Outcome,
      categoryName: 'Groceries',
    ),
    TransactionModel(
      102,
      1,
      1,
      'Salary Deposit',
      3000.00,
      DateTime(2026, 1, 1),
      TransactionType.Income,
      categoryName: 'General',
    ),
  ];

  Widget createWidget({
    List<TransactionModel>? suggestions,
    List<AccountModel>? accounts,
    List<CategoryModel>? categories,
  }) {
    return MaterialApp(
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BulkTransactionsScreen(
        accountRepository: FakeAccountRepository(accounts ?? [testAccount, otherAccount, cashAccount]),
        categoryRepository: FakeCategoryRepository(categories ?? testCategories),
        transactionRepository: FakeTransactionRepository(suggestionsToReturn: suggestions ?? testSuggestions),
        transactionService: FakeTransactionService(),
      ),
    );
  }

  testWidgets('shows both transaction suggestions and account names in autocomplete options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Find the description TextField (inside Autocomplete)
    final descriptionField = find.widgetWithText(TextField, 'Description');
    expect(descriptionField, findsOneWidget);

    await tester.tap(descriptionField);
    await tester.pump();
    await tester.enterText(descriptionField, 'super');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Supermarket Groceries'), findsOneWidget);
    expect(find.text('Groceries - \$45.5'), findsOneWidget);

    // Type query matching account name
    await tester.enterText(descriptionField, 'savings');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Savings Vault'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Account'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('selecting transaction suggestion populates description, price, category, type, and account',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final descriptionField = find.widgetWithText(TextField, 'Description');
    await tester.tap(descriptionField);
    await tester.pump();
    await tester.enterText(descriptionField, 'super');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Supermarket Groceries'), findsOneWidget);

    await tester.tap(find.text('Supermarket Groceries'));
    await tester.pumpAndSettle();

    final descEditable = tester.widget<TextField>(descriptionField);
    expect(descEditable.controller?.text, equals('Supermarket Groceries'));

    final amountField = find.widgetWithText(TextField, 'Amount');
    final amountEditable = tester.widget<TextField>(amountField);
    expect(amountEditable.controller?.text, equals('45.5'));

    // Account dropdown should show Savings Vault (accountId: 2)
    expect(
      find.widgetWithText(DropdownButtonFormField<AccountModel>, 'Savings Vault'),
      findsOneWidget,
    );
    // Category dropdown should show Groceries
    expect(
      find.widgetWithText(DropdownButtonFormField<CategoryModel>, 'Groceries'),
      findsOneWidget,
    );
    // Type dropdown should show Outcome
    expect(
      find.widgetWithText(DropdownButtonFormField<TransactionType>, 'Outcome'),
      findsOneWidget,
    );
  });

  testWidgets('selecting account suggestion populates description and account',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final descriptionField = find.widgetWithText(TextField, 'Description');
    await tester.tap(descriptionField);
    await tester.pump();
    await tester.enterText(descriptionField, 'vault');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Savings Vault'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Account'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Savings Vault'));
    await tester.pumpAndSettle();

    final descEditable = tester.widget<TextField>(descriptionField);
    expect(descEditable.controller?.text, equals('Savings Vault'));

    // Account dropdown should show Savings Vault
    expect(
      find.widgetWithText(DropdownButtonFormField<AccountModel>, 'Savings Vault'),
      findsOneWidget,
    );

    // Amount field should still be empty
    final amountField = find.widgetWithText(TextField, 'Amount');
    final amountEditable = tester.widget<TextField>(amountField);
    expect(amountEditable.controller?.text, isEmpty);
  });

  testWidgets('adds to queue with autocompleted values',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final descriptionField = find.widgetWithText(TextField, 'Description');
    await tester.tap(descriptionField);
    await tester.pump();
    await tester.enterText(descriptionField, 'super');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Supermarket Groceries'));
    await tester.pumpAndSettle();

    final addButton = find.text('Add to queue');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Queued (1)'), findsOneWidget);
    expect(find.text('Supermarket Groceries'), findsOneWidget);
  });
}
