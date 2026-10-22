import 'package:flutter/material.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/local_read_failed_exception.dart';
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
    final List<CategoryModel> result;
    try {
      result = await categoryService.fetch();
    } on LocalReadFailedException {
      notifierService?.notifyReadFailed();
      return;
    }
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
    } on LocalWriteFailedException catch (error) {
      notifierService?.notifyWriteRejected(error);
      // The sheet that asked must stay open, so it must not see a success.
      rethrow;
    }
  }

  Future update(CategoryModel category) async {
    try {
      await categoryService.update(category);
      // Once saved, what the list shows is what was saved, whatever instance the
      // caller passed. A renamed category also goes to its place in the order.
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) categories[index] = category;
      categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } on LocalWriteFailedException catch (error) {
      notifierService?.notifyWriteRejected(error);
      // A caller that edited the model before saving gets the stored values back.
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
    } on LocalWriteFailedException catch (error) {
      notifierService?.notifyWriteRejected(error);
    }
  }

  /// Turns a category on or off. An inactive category keeps its history but is no
  /// longer offered when adding a transaction (in local mode, see [selectable]).
  ///
  /// The category is only replaced once the change is saved, so a failed save
  /// leaves what is shown as it was. Returns whether it was saved.
  Future<bool> setActive(CategoryModel category, bool isActive) async {
    final updated = CategoryModel(category.id, category.userId, category.name,
        category.icon, category.measurable, isActive, category.color);
    try {
      await categoryService.update(updated);
    } on LocalWriteFailedException catch (error) {
      notifierService?.notifyWriteRejected(error);
      return false;
    }
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) categories[index] = updated;
    notifyListeners();
    return true;
  }

  /// The categories to offer when choosing one for a transaction. With [onlyActive],
  /// the inactive ones are left out, except [keep], which an existing transaction
  /// may already have. Never empty: if every category were switched off, all of them
  /// are offered, so the picker can't end up with nothing to choose.
  static List<CategoryModel> selectable(List<CategoryModel> all,
      {required bool onlyActive, int? keep}) {
    if (!onlyActive) return all;
    final chosen =
        all.where((c) => c.isActive || c.id == keep).toList(growable: false);
    return chosen.isEmpty ? all : chosen;
  }

  List<CategoryModel> getActiveCategories() {
    var activeCategories = categories.where((element) => element.isActive).toList();
    activeCategories.sort((a, b) => a.name.compareTo(b.name));
    return activeCategories;
  }
}
