import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../models/category.dart';
import '../../../services/repositories/category.repository.dart';

class EditCategorySheet extends StatefulWidget {
  final CategoryModel category;
  const EditCategorySheet({required this.category});

  @override
  State<EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<EditCategorySheet> {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController _categoryNameController = TextEditingController();
  CategoryModel category = CategoryModel.create('');

  @override
  Widget build(BuildContext context) {
    _categoryNameController.text = widget.category.name;
    return Row(
      children: [
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(
              labelText: 'Category name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            widget.category.name = _categoryNameController.text;
            _categoryRepository.update(widget.category);
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
