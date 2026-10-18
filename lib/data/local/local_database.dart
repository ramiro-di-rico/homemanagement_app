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

  /// Unique ignoring case: see the `categories_name_lower` index in `onCreate`.
  TextColumn get name => text().withLength(min: 1, max: 100)();
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

@DriftDatabase(
    tables: [Currencies, Accounts, Categories, Transactions, ImportStates])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.e);

  static const int singleImportStateId = 1;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE UNIQUE INDEX categories_name_lower ON categories (lower(name))');
          await customStatement(
              'CREATE INDEX transactions_account_date ON transactions (account_id, date DESC, id DESC)');
          await _seed();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

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
          CategoriesCompanion.insert(name: name, icon: icon),
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
