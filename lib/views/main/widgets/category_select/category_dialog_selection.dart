import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../models/category.dart';
import '../../../../services/repositories/category.repository.dart';
import 'category_select_model.dart';

class CategoryDialogSelection extends StatefulWidget {
  final Function(List<CategoryModel>) onSelectedCategoriesChanged;
  final List<CategoryModel> selectedCategories;
  final bool multipleSelection;

  CategoryDialogSelection({
    required this.onSelectedCategoriesChanged,
    this.multipleSelection = false,
    this.selectedCategories = const [],
  });

  @override
  State<CategoryDialogSelection> createState() =>
      _CategoryDialogSelectionState();
}

class _CategoryDialogSelectionState extends State<CategoryDialogSelection> {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  List<CategorySelectModel> _allCategories = [];
  CategorySelectModel? _selectedCategory;

  @override
  void initState() {
    super.initState();

    if (widget.selectedCategories.isNotEmpty) {
      _allCategories.addAll(_categoryRepository.categories
          .map((category) => CategorySelectModel(category, false))
          .toList());
      for (var category in widget.selectedCategories) {
        for (var categoryModel in _allCategories) {
          if (category.id == categoryModel.category.id) {
            categoryModel.isSelected = true;
            _selectedCategory = categoryModel;
          }
        }
      }
    } else {
      _allCategories.addAll(_categoryRepository.categories
          .map((category) => CategorySelectModel(category, false))
          .toList());
      _selectedCategory = _allCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.multipleSelection ? 'Select categories' : 'Select category'),
      content: SizedBox(
        height: 400,
        width: 200,
        child: Column(
          children: [
            widget.multipleSelection ?
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: CheckboxListTile(
                  value: _allCategories.every((category) => category.isSelected),
                  onChanged: (value) {
                    setState(() {
                      _allCategories.forEach((category) {
                        category.isSelected = value!;
                      });
                      widget.onSelectedCategoriesChanged(_allCategories
                          .where((category) => category.isSelected)
                          .map((category) => category.category)
                          .toList());
                    });
                  },
                  title: Text('Select all'),
              ),
            ) : Container(),
            SizedBox(height: 20),
            SizedBox(
              height: 330,
              width: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _allCategories.length,
                itemBuilder: (context, index) {
                  var categoryItem = _allCategories[index];

                  return widget.multipleSelection
                      ? CheckboxListTile(
                          title: Text(_allCategories[index].category.name),
                          value: _allCategories[index].isSelected,
                          onChanged: (value) {
                            setState(() {
                              _allCategories[index].isSelected = value!;
                              if (widget.multipleSelection) {
                                widget.onSelectedCategoriesChanged(_allCategories
                                    .where((category) => category.isSelected)
                                    .map((category) => category.category)
                                    .toList());
                              } else {
                                if (_selectedCategory != null) {
                                  _selectedCategory!.isSelected = false;
                                }
                                _selectedCategory = _allCategories[index];
                                _selectedCategory!.isSelected = true;
                                widget.onSelectedCategoriesChanged(
                                    [_selectedCategory!.category]);
                              }
                            });
                          },
                        )
                      : RadioListTile(
                          title: Text(categoryItem.category.name),
                          value: categoryItem,
                          groupValue: _selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedCategory!.isSelected = true;
                              widget.onSelectedCategoriesChanged([categoryItem.category]);
                            });
                            Navigator.of(context).pop();
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _selectedCategory = null;
            widget.onSelectedCategoriesChanged([]);
            Navigator.of(context).pop();
          },
          child: Text('Clear'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ok'),
        ),
      ],
    );
  }
}
