import 'package:drift/drift.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/domain/models/category.dart';

import 'local_database.dart';
import 'local_write_guard.dart';
import 'local_mappers.dart';

class LocalCategoryService implements CategoryDataSource {
  final LocalDatabase _db;

  LocalCategoryService(this._db);

  /// Includes inactive categories. Filtering stays in `CategoryRepository`.
  @override
  Future<List<CategoryModel>> fetch() async {
    final rows = await (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
    return rows.map((c) => c.toModel()).toList();
  }

  @override
  Future<CategoryModel> add(CategoryModel category) => guardWrite(() async {
    final name = _validName(category.name);
    await _ensureNameFree(name, exceptId: null);
    final id = await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: name,
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
  Future update(CategoryModel category) => guardWrite(() async {
    final name = _validName(category.name);
    await _ensureNameFree(name, exceptId: category.id);
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id)))
        .write(CategoriesCompanion(
      name: Value(name),
      icon: Value(category.icon),
      color: Value(category.color),
      measurable: Value(category.measurable),
      isActive: Value(category.isActive),
    ));
  });

  @override
  Future delete(CategoryModel category) => guardWrite(() async {
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
      ..where((c) => c.name.lower().equals(name.toLowerCase()));
    if (exceptId != null) query.where((c) => c.id.equals(exceptId).not());
    if ((await query.get()).isNotEmpty) throw CategoryNameTakenException();
  }

  String _validName(String raw) {
    final name = raw.trim();
    if (name.isEmpty || name.length > 100) {
      throw ArgumentError.value(raw, 'name', 'must be 1 to 100 characters');
    }
    return name;
  }
}
