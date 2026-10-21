import 'package:home_management_app/data/local/local_account.service.dart';
import 'package:home_management_app/data/local/local_category.service.dart';
import 'package:home_management_app/data/local/local_currency.service.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_transaction.service.dart';
import 'package:home_management_app/data/models/transaction-with-balance.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/sources/account_data_source.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/data/services/sources/local_data_locked_exception.dart';
import 'package:home_management_app/data/services/sources/transaction_data_source.dart';
import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/domain/models/transaction.dart';
import 'package:home_management_app/domain/models/transaction.page.dart';

/// Picks the remote source, or a local one built on the current database.
/// Decided on every call, so flipping [AppModeService] reroutes the repositories.
class _ModeSwitch<T> {
  final T remote;
  final AppModeService appMode;
  final T Function(LocalDatabase) _createLocal;
  T? _local;
  LocalDatabase? _localDatabase;

  _ModeSwitch(this.remote, this.appMode, this._createLocal);

  T get current {
    if (!appMode.isLocal) return remote;
    final database = appMode.database!;
    if (!identical(database, _localDatabase)) {
      _local = _createLocal(database);
      _localDatabase = database;
    }
    return _local as T;
  }

  /// The source for a write. Local data is read-only while an import is pending,
  /// so the data sent can't drift from what is kept (FR-022).
  T get writable {
    if (appMode.isLocal && appMode.isImportPending) {
      throw LocalDataLockedException();
    }
    return current;
  }
}

class ModeAwareAccountDataSource implements AccountDataSource {
  final _ModeSwitch<AccountDataSource> _source;

  ModeAwareAccountDataSource(AccountDataSource remote, AppModeService appMode)
      : _source = _ModeSwitch(remote, appMode, LocalAccountService.new);

  @override
  Future<List<AccountModel>> fetchAccounts() => _source.current.fetchAccounts();

  @override
  Future<AccountModel> add(AccountModel account) async => _source.writable.add(account);

  @override
  Future update(AccountModel account) async => _source.writable.update(account);

  @override
  Future delete(AccountModel account) async => _source.writable.delete(account);
}

class ModeAwareCategoryDataSource implements CategoryDataSource {
  final _ModeSwitch<CategoryDataSource> _source;

  ModeAwareCategoryDataSource(CategoryDataSource remote, AppModeService appMode)
      : _source = _ModeSwitch(remote, appMode, LocalCategoryService.new);

  @override
  Future<List<CategoryModel>> fetch() => _source.current.fetch();

  @override
  Future<CategoryModel> add(CategoryModel category) async =>
      _source.writable.add(category);

  @override
  Future update(CategoryModel category) async => _source.writable.update(category);

  @override
  Future delete(CategoryModel category) async => _source.writable.delete(category);
}

class ModeAwareCurrencyDataSource implements CurrencyDataSource {
  final _ModeSwitch<CurrencyDataSource> _source;

  ModeAwareCurrencyDataSource(CurrencyDataSource remote, AppModeService appMode)
      : _source = _ModeSwitch(remote, appMode, LocalCurrencyService.new);

  @override
  Future<List<CurrencyModel>> fetchCurrencies() =>
      _source.current.fetchCurrencies();
}

class ModeAwareTransactionDataSource implements TransactionDataSource {
  final _ModeSwitch<TransactionDataSource> _source;

  ModeAwareTransactionDataSource(
      TransactionDataSource remote, AppModeService appMode)
      : _source = _ModeSwitch(remote, appMode, LocalTransactionService.new);

  @override
  Future<List<TransactionModel>> page(TransactionPageModel page) =>
      _source.current.page(page);

  @override
  Future<List<TransactionModel>> pageNameFiltering(
          TransactionPageModel page, String name) =>
      _source.current.pageNameFiltering(page, name);

  @override
  Future<List<TransactionModel>> suggested() => _source.current.suggested();

  @override
  Future<TransactionWithBalanceModel> add(TransactionModel transaction) async =>
      _source.writable.add(transaction);

  @override
  Future update(TransactionModel transaction) async =>
      _source.writable.update(transaction);

  @override
  Future delete(int id) async => _source.writable.delete(id);
}
