import 'package:flutter/material.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';

class CategoryRepository extends ChangeNotifier {
  CategoryDataSource categoryService;
  final NotifierService? notifierService;
  final List<CategoryModel> categories = [];

  CategoryRepository(this.categoryService, {this.notifierService});

  /// Forgets everything held in memory, for a change between local and online data.
  void reset() {
    categories.clear();
    notifyListeners();
  }

  Future load() async {
    // Fetch before clearing, so a failed read keeps what is already shown.
    var result = await categoryService.fetch();
    categories.clear();
    categories.addAll(result);
    categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future add(CategoryModel category) async {
    try {
      var addedCategory = await categoryService.add(category);
      categories.add(addedCategory);
      categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } on LocalWriteFailedException {
      notifierService?.notifyChangeNotSaved();
      // The sheet that asked must stay open, so it must not see a success.
      rethrow;
    }
  }

  Future update(CategoryModel category) async {
    try {
      await categoryService.update(category);
      notifyListeners();
    } on LocalWriteFailedException {
      notifierService?.notifyChangeNotSaved();
      // The caller edited the model before saving, so take the stored values back.
      try {
        await load();
      } catch (_) {
        // Keep what is shown if the stored values can't be read either.
      }
      rethrow;
    }
  }

  Future delete(CategoryModel category) async {
    try {
      await categoryService.delete(category);
      categories.removeWhere((element) => element.id == category.id);
      categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } on LocalWriteFailedException {
      notifierService?.notifyChangeNotSaved();
    }
  }

  List<CategoryModel> getActiveCategories() {
    var activeCategories = categories.where((element) => element.isActive).toList();
    activeCategories.sort((a, b) => a.name.compareTo(b.name));
    return activeCategories;
  }
}
