import 'package:flutter/material.dart';

import '../../../../models/category.dart';
import 'category_dialog_selection.dart';

class CategorySelect extends StatefulWidget {
  final Function(List<CategoryModel>) onSelectedCategoriesChanged;
  final List<CategoryModel> selectedCategories;
  final bool multipleSelection;

  CategorySelect({
    required this.onSelectedCategoriesChanged,
    this.multipleSelection = false,
    this.selectedCategories = const [],
  });

  @override
  State<CategorySelect> createState() => _CategorySelectState();
}

class _CategorySelectState extends State<CategorySelect> {
  TextEditingController _selectedCategoriesTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoriesTextEditingController.text =
        widget.selectedCategories.map((category) => category.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: this.context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CategoryDialogSelection(
                onSelectedCategoriesChanged: (selectedCategories) {
                  widget.onSelectedCategoriesChanged(selectedCategories);
                  _selectedCategoriesTextEditingController.text =
                      selectedCategories
                          .map((category) => category.name)
                          .join(', ');
                },
                multipleSelection: widget.multipleSelection,
                selectedCategories: widget.selectedCategories,
              );
            });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.labelLarge?.color,
                  ),
                  controller: _selectedCategoriesTextEditingController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: widget.multipleSelection
                        ? 'Select categories'
                        : 'Select category',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: this.context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return CategoryDialogSelection(
                          onSelectedCategoriesChanged: (selectedCategories) {
                            widget.onSelectedCategoriesChanged(
                                selectedCategories);
                            _selectedCategoriesTextEditingController.text =
                                selectedCategories
                                    .map((category) => category.name)
                                    .join(', ');
                          },
                          multipleSelection: widget.multipleSelection,
                          selectedCategories: widget.selectedCategories,
                        );
                      });
                },
                icon: Icon(widget.multipleSelection
                    ? Icons.view_list
                    : Icons.arrow_drop_down),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
