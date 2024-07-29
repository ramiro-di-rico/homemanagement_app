import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/services/repositories/user.repository.dart';

import '../../../models/category.dart';
import '../../../services/repositories/category.repository.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController _categoryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            var category = CategoryModel.create(_categoryNameController.text);
            _categoryRepository.add(category);
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
