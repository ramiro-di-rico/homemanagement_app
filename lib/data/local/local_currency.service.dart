import 'package:drift/drift.dart';
import 'package:home_management_app/data/services/sources/currency_data_source.dart';
import 'package:home_management_app/domain/models/currency.dart';

import 'local_database.dart';
import 'local_mappers.dart';

class LocalCurrencyService implements CurrencyDataSource {
  final LocalDatabase _db;

  LocalCurrencyService(this._db);

  @override
  Future<List<CurrencyModel>> fetchCurrencies() async {
    final rows = await (_db.select(_db.currencies)
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
    return rows.map((c) => c.toModel()).toList();
  }
}
