import 'package:flutter/material.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/services/endpoints/category.service.dart';

class CategoryRepository extends ChangeNotifier {
  CategoryService categoryService;
  final List<CategoryModel> categories = [];
  final List<CategoryModel> activeCategories = [];

  CategoryRepository(this.categoryService);

  Future load() async {
    var result = await categoryService.fetch();
    categories.addAll(result);
    activeCategories
        .addAll(categories.where((element) => element.isActive).toList());
    categories.sort((a, b) => a.name.compareTo(b.name));
    activeCategories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }
}
