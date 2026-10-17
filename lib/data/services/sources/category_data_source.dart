import 'package:home_management_app/domain/models/category.dart';

abstract interface class CategoryDataSource {
  /// Includes inactive categories.
  Future<List<CategoryModel>> fetch();

  Future<CategoryModel> add(CategoryModel category);

  Future update(CategoryModel category);

  /// Local implementation throws [CategoryInUseException] when a transaction uses the category.
  Future delete(CategoryModel category);
}

class CategoryInUseException implements Exception {
  @override
  String toString() => 'CategoryInUseException';
}
