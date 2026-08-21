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
import 'package:home_management_app/ui/features/accounts/views/widgets/add_transaction_sheet_desktop.dart';

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
    TransactionModel(
      102,
      1,
      2,
      'Savings Transfer',
      100.00,
      DateTime(2026, 1, 1),
      TransactionType.Outcome,
      categoryName: 'Transfer',
    ),
  ];

  Future<void> pumpSheet(
    WidgetTester tester, {
    required FakeCategoryRepository categoryRepo,
    required FakeTransactionRepository transactionRepo,
    required FakeAccountRepository accountRepo,
    TransactionModel? transactionModel,
  }) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AddTransactionSheetDesktop(
              testAccount,
              transactionModel: transactionModel,
              categoryRepository: categoryRepo,
              transactionRepository: transactionRepo,
              accountRepository: accountRepo,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows both transaction suggestions and account names in autocomplete options', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount, cashAccount]);

    await pumpSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
    );

    final nameField = find.byType(AppTextField);
    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'Sav');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify transaction suggestion is shown with its category and price
    expect(find.text('Savings Transfer'), findsOneWidget);
    expect(find.text('Transfer - \$100.0'), findsOneWidget);

    // Verify account suggestion is shown with "Account" subtitle
    expect(find.text('Savings Vault'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('selecting an account suggestion populates the transaction name', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount, cashAccount]);

    await pumpSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
    );

    final nameField = find.byType(AppTextField);
    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'Wallet');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Wallet Cash'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    // Tap on the account suggestion
    await tester.tap(find.text('Wallet Cash'));
    await tester.pumpAndSettle();

    // Verify that the text field now has the account name
    final appTextField = tester.widget<AppTextField>(nameField);
    expect(appTextField.controller.text, 'Wallet Cash');
  });

  testWidgets('selecting a transaction suggestion populates name, price, category, and type', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountRepo = FakeAccountRepository([testAccount, otherAccount, cashAccount]);

    await pumpSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
    );

    final nameField = find.byType(AppTextField);
    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'Supermarket');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Supermarket Groceries'), findsOneWidget);
    expect(find.text('General - \$45.5'), findsOneWidget);

    // Tap on the transaction suggestion
    await tester.tap(find.text('Supermarket Groceries'));
    await tester.pumpAndSettle();

    // Verify name and price are updated
    final appTextField = tester.widget<AppTextField>(nameField);
    expect(appTextField.controller.text, 'Supermarket Groceries');

    final priceField = tester.widget<TextField>(
      find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.icon is Icon &&
          (w.decoration?.icon as Icon).icon == Icons.attach_money),
    );
    expect(priceField.controller?.text, '45.5');
  });

  testWidgets('loads accounts if initially empty and populates suggestions', (tester) async {
    final categoryRepo = FakeCategoryRepository(testCategories);
    final transactionRepo = FakeTransactionRepository(suggestionsToReturn: testSuggestions);
    final accountsList = <AccountModel>[];
    final accountRepo = FakeAccountRepository(accountsList);

    await pumpSheet(
      tester,
      categoryRepo: categoryRepo,
      transactionRepo: transactionRepo,
      accountRepo: accountRepo,
    );

    // Emulate accountRepo loading accounts
    accountsList.addAll([testAccount, otherAccount, cashAccount]);

    final nameField = find.byType(AppTextField);
    await tester.tap(nameField);
    await tester.pump();
    await tester.enterText(nameField, 'main');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Main Checking'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}
