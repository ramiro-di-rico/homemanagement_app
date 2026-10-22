import 'package:drift/drift.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/local_record_not_found_exception.dart';
import 'package:home_management_app/domain/models/category.dart';

import 'local_database.dart';
import 'local_write_guard.dart';
import 'local_mappers.dart';

class LocalCategoryService implements CategoryDataSource {
  final LocalDatabase _db;

  LocalCategoryService(this._db);

  /// Includes inactive categories. Filtering stays in `CategoryRepository`.
  @override
  Future<List<CategoryModel>> fetch() => guardRead(() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
    return rows.map((c) => c.toModel()).toList();
  });

  @override
  Future<CategoryModel> add(CategoryModel category) => guardedTransaction(_db, () async {
    final name = validName(category.name);
    await _ensureNameFree(name, exceptId: null);
    final id = await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: name,
          nameKey: Value(categoryNameKey(name)),
          icon: category.icon,
          color: Value(category.color),
          measurable: Value(category.measurable),
          isActive: Value(category.isActive),
        ));
    final created = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingle();
    return created.toModel();
  });

  @override
  Future update(CategoryModel category) => guardedTransaction(_db, () async {
    final name = validName(category.name);
    await _ensureNameFree(name, exceptId: category.id);
    final changed = await (_db.update(_db.categories)
          ..where((c) => c.id.equals(category.id)))
        .write(CategoriesCompanion(
      name: Value(name),
      nameKey: Value(categoryNameKey(name)),
      icon: Value(category.icon),
      color: Value(category.color),
      measurable: Value(category.measurable),
      isActive: Value(category.isActive),
    ));
    if (changed == 0) throw LocalRecordNotFoundException('category', category.id);
  });

  /// Deleting one that is already gone is not an error: it is not there, which is
  /// what was asked for.
  @override
  Future delete(CategoryModel category) => guardedTransaction(_db, () async {
    final used = await (_db.select(_db.transactions)
          ..where((t) => t.categoryId.equals(category.id))
          ..limit(1))
        .get();
    if (used.isNotEmpty) throw CategoryInUseException();
    await (_db.delete(_db.categories)..where((c) => c.id.equals(category.id)))
        .go();
  });

  Future<void> _ensureNameFree(String name, {required int? exceptId}) async {
    final query = _db.select(_db.categories)
      ..where((c) => c.nameKey.equals(categoryNameKey(name)));
    if (exceptId != null) query.where((c) => c.id.equals(exceptId).not());
    if ((await query.get()).isNotEmpty) throw CategoryNameTakenException();
  }
}
