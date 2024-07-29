import 'package:flutter/material.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/services/endpoints/category.service.dart';

class CategoryRepository extends ChangeNotifier {
  CategoryService categoryService;
  final List<CategoryModel> categories = [];

  CategoryRepository(this.categoryService);

  Future load() async {
    categories.clear();
    var result = await categoryService.fetch();
    categories.addAll(result);
    categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future add(CategoryModel category) async {
    var addedCategory = await categoryService.add(category);
    categories.add(addedCategory);
    categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future update(CategoryModel category) async {
    var updatedCategory = await categoryService.update(category);
    var index = categories.indexWhere((element) => element.id == category.id);
    categories[index] = updatedCategory;
    categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future delete(CategoryModel category) async {
    await categoryService.delete(category);
    categories.removeWhere((element) => element.id == category.id);
    categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  List<CategoryModel> getActiveCategories() {
    var activeCategories = categories.where((element) => element.isActive).toList();
    activeCategories.sort((a, b) => a.name.compareTo(b.name));
    return activeCategories;
  }
}
