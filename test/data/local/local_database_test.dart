import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';

void main() {
  late LocalDatabase db;

  setUp(() => db = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addAccount([String name = 'Main']) =>
      db.into(db.accounts).insert(
          AccountsCompanion.insert(name: name, accountType: 0, currencyId: 1));

  Future<int> addTransaction(int accountId, int categoryId, {double amount = 10}) =>
      db.into(db.transactions).insert(TransactionsCompanion.insert(
            accountId: accountId,
            categoryId: categoryId,
            name: 'Coffee',
            amount: amount,
            transactionType: 1,
            date: DateTime.utc(2026, 1, 1),
            createdAt: DateTime.utc(2026, 1, 1),
          ));

  test('seeds 3 currencies, 17 active categories and the import state', () async {
    final currencies = await db.select(db.currencies).get();
    expect(currencies.map((c) => (c.id, c.name, c.value)),
        [(1, 'USD', 1.0), (2, 'ARS', 0.0), (3, 'EUR', 0.0)]);

    final categories = await db.select(db.categories).get();
    expect(categories, hasLength(17));
    expect(categories.every((c) => c.isActive && c.measurable), isTrue);
    expect(categories.first.name, 'Various');
    expect(categories.first.icon, 'layers');

    final state = await db.select(db.importStates).getSingle();
    expect(state.id, 1);
    expect(state.status, ImportStatus.notStarted);
  });

  test('foreign keys are enforced', () async {
    await expectLater(addTransaction(999, 1), throwsA(isA<Exception>()));
  });

  test('a used account and a used category cannot be deleted', () async {
    final accountId = await addAccount();
    await addTransaction(accountId, 1);

    await expectLater(
        (db.delete(db.accounts)..where((a) => a.id.equals(accountId))).go(),
        throwsA(isA<Exception>()));
    await expectLater(
        (db.delete(db.categories)..where((c) => c.id.equals(1))).go(),
        throwsA(isA<Exception>()));
  });

  test('amount must be greater than 0', () async {
    final accountId = await addAccount();
    await expectLater(addTransaction(accountId, 1, amount: 0), throwsA(isA<Exception>()));
    await expectLater(addTransaction(accountId, 1, amount: -5), throwsA(isA<Exception>()));
  });

  test('category names are unique ignoring case', () async {
    await expectLater(
        db.into(db.categories).insert(
            CategoriesCompanion.insert(name: 'RENT', icon: 'home')),
        throwsA(isA<Exception>()));
  });

  test('name lengths are checked', () async {
    await expectLater(
        db.into(db.accounts).insert(AccountsCompanion.insert(
            name: '', accountType: 0, currencyId: 1)),
        throwsA(isA<Exception>()));
  });
}
