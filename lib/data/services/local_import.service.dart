import 'dart:math';

import 'package:drift/drift.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_mappers.dart';
import 'package:home_management_app/data/models/import_mismatch.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/models/import_result.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/bulk_transaction_client.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/sources/import_currency_missing_exception.dart';
import 'package:home_management_app/data/services/sources/import_server_not_ready_exception.dart';
import 'package:home_management_app/data/services/sources/import_wrong_user_exception.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';

/// Moves the local database into the account the user just created (see
/// `data-model.md`, "Import"). Every step can be repeated, so a failed run is
/// resumed by calling [run] again.
class LocalImportService {
  static const double _balanceTolerance = 0.005;
  static final RegExp _temporaryName = RegExp(
    r'^(.*) ⟨import ([0-9a-f]+)-[^⟩]*⟩$',
  );

  final LocalDatabase _db;
  final AccountDataSource _accounts;
  final CategoryDataSource _categories;
  final CurrencyDataSource _currencies;
  final BulkTransactionClient _transactions;
  final Random _random;
  final Duration _serverReadyTimeout;
  final Future<void> Function(Duration) _delay;

  LocalImportService({
    required LocalDatabase database,
    required AccountDataSource accounts,
    required CategoryDataSource categories,
    required CurrencyDataSource currencies,
    required BulkTransactionClient transactions,
    Random? random,
    Duration serverReadyTimeout = const Duration(seconds: 30),
    Future<void> Function(Duration)? delay,
  }) : _serverReadyTimeout = serverReadyTimeout,
       _delay = delay ?? Future<void>.delayed,
       _db = database,
       _accounts = accounts,
       _categories = categories,
       _currencies = currencies,
       _transactions = transactions,
       _random = random ?? Random.secure();

  /// Name an account carries on the server while its transactions are sent. No
  /// transaction can be named like it, so the server creates no mirror
  /// transaction (research R6). [suffix] is the local account id, or `default`.
  static String temporaryName(String name, String tag, Object suffix) =>
      '$name ⟨import $tag-$suffix⟩';

  Future<ImportResult> run({
    required String email,
    ImportProgress? onProgress,
  }) async {
    final tag = await _begin(email);
    try {
      final currencyIds = await _preflight(onProgress);
      await _waitForServer(onProgress);
      final categoryIds = await _importCategories(onProgress);
      await _importAccounts(tag, currencyIds, onProgress);
      await _importTransactions(categoryIds, onProgress);
      await _restoreNames(tag, currencyIds, onProgress);
      final mismatches = await _verify(onProgress);
      await _setState(ImportStatus.completed, lastError: const Value(null));
      return ImportResult(mismatches);
    } catch (error) {
      await _setState(ImportStatus.failed, lastError: Value(error.toString()));
      rethrow;
    }
  }

  // Step 0

  Future<String> _begin(String email) async {
    final state = await _state();
    final pending =
        state.status == ImportStatus.registered ||
        state.status == ImportStatus.inProgress ||
        state.status == ImportStatus.failed;
    final target = state.targetEmail;
    if (pending &&
        target != null &&
        target.trim().toLowerCase() != email.trim().toLowerCase()) {
      throw ImportWrongUserException(target);
    }
    final tag = state.importTag ?? _newTag();
    await (_db.update(
      _db.importStates,
    )..where((s) => s.id.equals(LocalDatabase.singleImportStateId))).write(
      ImportStatesCompanion(
        status: const Value(ImportStatus.inProgress),
        targetEmail: Value(email),
        startedAt: Value(state.startedAt ?? DateTime.now().toUtc()),
        importTag: Value(tag),
        lastError: const Value(null),
      ),
    );
    return tag;
  }

  String _newTag() =>
      List.generate(8, (_) => _random.nextInt(16).toRadixString(16)).join();

  Future<LocalImportState> _state() => (_db.select(
    _db.importStates,
  )..where((s) => s.id.equals(LocalDatabase.singleImportStateId))).getSingle();

  Future<void> _setState(
    ImportStatus status, {
    required Value<String?> lastError,
  }) async {
    await (_db.update(
      _db.importStates,
    )..where((s) => s.id.equals(LocalDatabase.singleImportStateId))).write(
      ImportStatesCompanion(status: Value(status), lastError: lastError),
    );
  }

  // Step 1

  /// Returns local currency id -> server currency id.
  Future<Map<int, int>> _preflight(ImportProgress? onProgress) async {
    final server = {
      for (final c in await _currencies.fetchCurrencies())
        c.name.toLowerCase(): c.id,
    };
    final local = {
      for (final c in await _db.select(_db.currencies).get()) c.id: c.name,
    };
    final used = (await _localAccounts()).map((a) => a.currencyId).toSet();
    final missing = <String>[];
    final map = <int, int>{};
    for (final id in used) {
      final name = local[id] ?? '$id';
      final serverId = server[name.toLowerCase()];
      if (serverId == null) {
        missing.add(name);
      } else {
        map[id] = serverId;
      }
    }
    onProgress?.call(ImportStep.preflight, 1, 1);
    if (missing.isNotEmpty) {
      throw ImportCurrencyMissingException(missing..sort());
    }
    return map;
  }

  // Step 1b

  /// Right after registering, the server hasn't created the user's default
  /// categories and Cash account yet: it does so in the background, in two saves.
  /// Importing before that sees empty lists, and anything created in between shows
  /// up again as a duplicate when the defaults arrive. So wait until the server
  /// has the seeded categories and at least one account, backing off from 1 to 5
  /// seconds, and give up (resumably) after [_serverReadyTimeout].
  Future<void> _waitForServer(ImportProgress? onProgress) async {
    final seeded = {
      for (final name in LocalDatabase.defaultCategoryNames)
        categoryNameKey(name),
    };
    var waited = Duration.zero;
    var step = const Duration(seconds: 1);
    for (var attempt = 1; ; attempt++) {
      onProgress?.call(ImportStep.serverSetup, attempt, 0);
      final categories = {
        for (final c in await _categories.fetch()) categoryNameKey(c.name),
      };
      final ready =
          categories.containsAll(seeded) &&
          (await _accounts.fetchAccounts()).isNotEmpty;
      if (ready) return;
      if (waited >= _serverReadyTimeout) {
        throw ImportServerNotReadyException(waited);
      }
      await _delay(step);
      waited += step;
      if (step < const Duration(seconds: 5)) step *= 2;
      if (step > const Duration(seconds: 5)) step = const Duration(seconds: 5);
    }
  }

  // Step 2

  /// Returns local category id -> server category id.
  Future<Map<int, int>> _importCategories(ImportProgress? onProgress) async {
    final remote = {
      for (final c in await _categories.fetch()) categoryNameKey(c.name): c,
    };
    final local = await (_db.select(
      _db.categories,
    )..orderBy([(c) => OrderingTerm.asc(c.id)])).get();
    final ids = <int, int>{};
    var done = 0;
    for (final category in local) {
      var server = remote[categoryNameKey(category.name)];
      // The server ignores icon, color, measurable and isActive on create (R4),
      // so a created category is always followed by an update. The same check
      // also repairs a category that was created before an earlier failure.
      server ??= await _categories.add(
        CategoryModel(
          0,
          0,
          category.name,
          category.icon,
          category.measurable,
          category.isActive,
          category.color,
        ),
      );
      if (server.icon != category.icon ||
          server.color != category.color ||
          server.measurable != category.measurable ||
          server.isActive != category.isActive) {
        await _categories.update(
          CategoryModel(
            server.id,
            server.userId,
            server.name,
            category.icon,
            category.measurable,
            category.isActive,
            category.color,
          ),
        );
      }
      await (_db.update(_db.categories)..where((c) => c.id.equals(category.id)))
          .write(CategoriesCompanion(serverId: Value(server.id)));
      ids[category.id] = server.id;
      onProgress?.call(ImportStep.categories, ++done, local.length);
    }
    return ids;
  }

  // Step 3

  Future<void> _importAccounts(
    String tag,
    Map<int, int> currencyIds,
    ImportProgress? onProgress,
  ) async {
    final remote = await _accounts.fetchAccounts();
    final localCurrencies = {
      for (final c in await _db.select(_db.currencies).get()) c.id: c.name,
    };
    final accounts = await _localAccounts();
    final mapped = {
      for (final a in accounts)
        if (a.serverId != null) a.serverId!,
    };
    var done = 0;

    for (final account in accounts) {
      if (account.serverId == null) {
        final temporary = temporaryName(account.name, tag, account.id);
        final serverCurrency = currencyIds[account.currencyId]!;
        // 1. An earlier attempt created it but died before storing its id.
        AccountModel? server = remote
            .where((r) => r.name == temporary)
            .firstOrNull;
        // 2. The server's own default "Cash" account stands for the local one.
        if (server == null &&
            account.name == 'Cash' &&
            account.accountType == 0 &&
            localCurrencies[account.currencyId]?.toLowerCase() == 'usd') {
          server = remote
              .where(
                (r) =>
                    r.name == 'Cash' &&
                    r.currencyId == serverCurrency &&
                    r.balance == 0 &&
                    !mapped.contains(r.id),
              )
              .firstOrNull;
          if (server != null) {
            server.name = temporary;
            await _accounts.update(server);
          }
        }
        // 3. A new account, created under its temporary name.
        server ??= await _accounts.add(
          AccountModel(
            0,
            temporary,
            0,
            account.measurable,
            account.accountType == 1
                ? AccountType.BankAccount
                : AccountType.Cash,
            serverCurrency,
            0,
            false,
            false,
          ),
        );
        await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
            .write(AccountsCompanion(serverId: Value(server.id)));
        mapped.add(server.id);
      }
      onProgress?.call(ImportStep.accounts, ++done, accounts.length);
    }

    // Every account of this user must have a temporary name before any bulk
    // request, so a transaction named like a real account matches none.
    var first = true;
    for (final server in remote) {
      if (mapped.contains(server.id) || _isTemporary(server.name, tag))
        continue;
      server.name = temporaryName(
        server.name,
        tag,
        first ? 'default' : 'default-${server.id}',
      );
      await _accounts.update(server);
      if (first) {
        await (_db.update(
          _db.importStates,
        )..where((s) => s.id.equals(LocalDatabase.singleImportStateId))).write(
          ImportStatesCompanion(defaultAccountServerId: Value(server.id)),
        );
        first = false;
      }
    }
  }

  bool _isTemporary(String name, String tag) =>
      _temporaryName.firstMatch(name)?.group(2) == tag;

  // Step 4

  Future<void> _importTransactions(
    Map<int, int> categoryIds,
    ImportProgress? onProgress,
  ) async {
    final categoryNames = {
      for (final c in await _db.select(_db.categories).get()) c.id: c.name,
    };
    final accounts = <LocalAccount>[];
    for (final account in await _localAccounts()) {
      final count =
          await (_db.selectOnly(_db.transactions)
                ..addColumns([_db.transactions.id.count()])
                ..where(_db.transactions.accountId.equals(account.id)))
              .map((r) => r.read(_db.transactions.id.count()))
              .getSingle();
      if ((count ?? 0) > 0) accounts.add(account);
    }

    var done = 0;
    for (final account in accounts) {
      if (!account.transactionsImported) {
        final serverId = account.serverId!;
        if (!await _transactions.hasTransactions(serverId)) {
          final rows =
              await (_db.select(_db.transactions)
                    ..where((t) => t.accountId.equals(account.id))
                    ..orderBy([
                      (t) => OrderingTerm.asc(t.date),
                      (t) => OrderingTerm.asc(t.id),
                    ]))
                  .get();
          await _transactions.bulkAdd([
            for (final row in rows)
              row.toModel(categoryNames[row.categoryId] ?? '')
                ..accountId = serverId
                ..categoryId = categoryIds[row.categoryId]!,
          ]);
        }
        await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
            .write(const AccountsCompanion(transactionsImported: Value(true)));
      }
      onProgress?.call(ImportStep.transactions, ++done, accounts.length);
    }
  }

  // Step 5

  Future<void> _restoreNames(
    String tag,
    Map<int, int> currencyIds,
    ImportProgress? onProgress,
  ) async {
    final remote = await _accounts.fetchAccounts();
    final local = {
      for (final a in await _localAccounts())
        if (a.serverId != null) a.serverId!: a,
    };
    final pending = remote.where((r) => _isTemporary(r.name, tag)).toList();
    var done = 0;
    for (final server in pending) {
      server.name = _temporaryName.firstMatch(server.name)!.group(1)!;
      final account = local[server.id];
      if (account != null) {
        // The create call can't set these, so the local values go in now.
        server
          ..name = account.name
          ..archive = account.archive
          ..measurable = account.measurable
          ..isHidden = account.isHidden;
      }
      await _accounts.update(server);
      onProgress?.call(ImportStep.restoring, ++done, pending.length);
    }
    if (pending.isEmpty) onProgress?.call(ImportStep.restoring, 0, 0);
  }

  // Step 6

  Future<List<ImportMismatch>> _verify(ImportProgress? onProgress) async {
    final remote = {for (final a in await _accounts.fetchAccounts()) a.id: a};
    final accounts = (await _localAccounts())
        .where((a) => a.serverId != null)
        .toList();
    final mismatches = <ImportMismatch>[];
    var done = 0;
    for (final account in accounts) {
      final local = await _db.accountBalance(account.id);
      final server = remote[account.serverId]?.balance ?? 0;
      if ((server - local).abs() > _balanceTolerance) {
        mismatches.add(ImportMismatch(account.name, local, server));
      }
      onProgress?.call(ImportStep.verifying, ++done, accounts.length);
    }
    if (accounts.isEmpty) onProgress?.call(ImportStep.verifying, 0, 0);
    return mismatches;
  }

  Future<List<LocalAccount>> _localAccounts() => (_db.select(
    _db.accounts,
  )..orderBy([(a) => OrderingTerm.asc(a.id)])).get();
}
