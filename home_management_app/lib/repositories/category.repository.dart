import 'package:flutter/material.dart';
import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/services/category.service.dart';

class CategoryRepository extends ChangeNotifier{
  CategoryService categoryService;
  final List<CategoryModel> categories = List<CategoryModel>();
  final List<CategoryModel> activeCategories = List<CategoryModel>();

  CategoryRepository(this.categoryService);

  Future load() async {
    var result = await categoryService.fetch();
    categories.addAll(result);
    activeCategories.addAll(categories.where((element) => element.isActive).toList());
    notifyListeners();
  }
}