import 'package:drift/drift.dart';

part 'local_database.g.dart';

/// Stored as its index in `import_states.status`. Append only.
enum ImportStatus { notStarted, inProgress, failed, completed }

@DataClassName('LocalCurrency')
class Currencies extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().unique()();
  RealColumn get value => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalAccount')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// 0 = Cash, 1 = BankAccount
  IntColumn get accountType => integer()();
  IntColumn get currencyId => integer().references(Currencies, #id)();
  BoolColumn get measurable => boolean().withDefault(const Constant(true))();
  BoolColumn get archive => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  IntColumn get serverId => integer().nullable().unique()();
  BoolColumn get transactionsImported =>
      boolean().withDefault(const Constant(false))();
}

@DataClassName('LocalCategory')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// [categoryNameKey] of the name. It is what must be unique, because SQLite's
  /// `lower()` only folds ASCII, so a unique index on `lower(name)` lets "Útiles"
  /// and "útiles" both in. The default only fills rows that existed before schema 2.
  TextColumn get nameKey => text().withDefault(const Constant(''))();
  TextColumn get icon => text()();
  TextColumn get color => text().withDefault(const Constant('#ffffff'))();
  BoolColumn get measurable => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get serverId => integer().nullable().unique()();
}

@DataClassName('LocalTransaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer()
      .references(Accounts, #id, onDelete: KeyAction.restrict)();
  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  // ignore: recursive_getters
  RealColumn get amount => real().check(amount.isBiggerThanValue(0))();

  /// 0 = Income, 1 = Outcome
  IntColumn get transactionType => integer()();

  /// UTC midnight of the chosen day.
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Holds a single row, `id = 1`.
@DataClassName('LocalImportState')
class ImportStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get status => intEnum<ImportStatus>()();
  TextColumn get targetEmail => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  /// 8 random hex chars. Makes the temporary account names unique to one import.
  TextColumn get importTag => text().nullable()();
  IntColumn get defaultAccountServerId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// How category names are compared: trimmed and lower-cased with Dart's Unicode
/// rules. The import (T065) must match server categories with this same folding.
String categoryNameKey(String name) => name.trim().toLowerCase();

@DriftDatabase(
    tables: [Currencies, Accounts, Categories, Transactions, ImportStates])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.e);

  static const int singleImportStateId = 1;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX categories_name_key ON categories (name_key)');
          await customStatement(
              'CREATE INDEX transactions_account_date ON transactions (account_id, date DESC, id DESC)');
          await _seed();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _addCategoryNameKey(m);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Schema 1 to 2: the uniqueness of category names moves from an ASCII-only
  /// `lower(name)` index to a `name_key` column folded in Dart.
  Future<void> _addCategoryNameKey(Migrator m) async {
    await m.addColumn(categories, categories.nameKey);
    final seen = <String>{};
    for (final category in await select(categories).get()) {
      var key = categoryNameKey(category.name);
      // Two names that only differed by accents used to be allowed. Keep both
      // rows, so no data is lost, and let the user rename one of them.
      if (!seen.add(key)) key = '$key #${category.id}';
      await (update(categories)..where((c) => c.id.equals(category.id)))
          .write(CategoriesCompanion(nameKey: Value(key)));
    }
    await customStatement('DROP INDEX IF EXISTS categories_name_lower');
    await customStatement(
        'CREATE UNIQUE INDEX categories_name_key ON categories (name_key)');
  }

  /// Income minus outcome for one account (FR-008). Balances are never stored.
  Future<double> accountBalance(int accountId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(CASE transaction_type WHEN 0 THEN amount ELSE -amount END), 0.0) AS balance '
      'FROM transactions WHERE account_id = ?',
      variables: [Variable.withInt(accountId)],
      readsFrom: {transactions},
    ).getSingle();
    return row.read<double>('balance');
  }

  /// Whether the user put anything here: an account, a transaction, or a change
  /// to the seeded categories (added, removed, renamed, restyled or deactivated).
  /// Without any of it there is nothing worth importing (US4 scenario 6).
  Future<bool> hasUserData() async {
    if ((await (select(accounts)..limit(1)).get()).isNotEmpty) return true;
    if ((await (select(transactions)..limit(1)).get()).isNotEmpty) return true;
    final current = await select(categories).get();
    if (current.length != _defaultCategories.length) return true;
    final seeded = {for (final (name, icon) in _defaultCategories) name: icon};
    return current.any((c) =>
        seeded[c.name] != c.icon ||
        c.color != '#ffffff' ||
        !c.measurable ||
        !c.isActive);
  }

  Future<void> _seed() async {
    await batch((b) {
      // Same rows as the server's CurrencySeed.
      b.insertAll(currencies, [
        CurrenciesCompanion.insert(id: const Value(1), name: 'USD', value: 1),
        CurrenciesCompanion.insert(id: const Value(2), name: 'ARS', value: 0),
        CurrenciesCompanion.insert(id: const Value(3), name: 'EUR', value: 0),
      ]);
      b.insertAll(categories, [
        for (final (name, icon) in _defaultCategories)
          CategoriesCompanion.insert(
              name: name, icon: icon, nameKey: Value(categoryNameKey(name))),
      ]);
      b.insert(
          importStates,
          ImportStatesCompanion.insert(
              id: const Value(singleImportStateId),
              status: ImportStatus.notStarted));
    });
  }

  /// Same names and icons as the server's `CategoryInitializer`.
  static const List<(String, String)> _defaultCategories = [
    ('Various', 'layers'),
    ('Rent', 'home'),
    ('Transportation', 'directions_bus'),
    ('Supplies', 'shopping_basket'),
    ('Entertainment', 'theaters'),
    ('Gift', 'card_giftcard'),
    ('Clothes', 'wc'),
    ('Education', 'book'),
    ('Health', 'healing'),
    ('Salary', 'attach_money'),
    ('Bond', 'local_atm'),
    ('Services', 'credit_card'),
    ('Savings', 'account_balance_wallet'),
    ('Transfers', 'compare_arrows'),
    ('Donations', 'child_care'),
    ('Extraction', 'autorenew'),
    ('Deposit', 'input'),
  ];
}
