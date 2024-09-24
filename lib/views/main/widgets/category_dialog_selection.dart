import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/category.repository.dart';
import '../../../services/transaction_paging_service.dart';

class CategoryDialogSelection extends StatefulWidget {
  const CategoryDialogSelection({super.key});

  @override
  State<CategoryDialogSelection> createState() => _CategoryDialogSelectionState();
}

class _CategoryDialogSelectionState extends State<CategoryDialogSelection> {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  TransactionPagingService _transactionPagingService = GetIt.I<TransactionPagingService>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select categories'),
      content: SizedBox(
        height: 400,
        width: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categoryRepository.categories.length,
          itemBuilder: (context, index) {
            var category = _categoryRepository.categories[index];

            var isSelected = _transactionPagingService.selectedCategories.any((element) => element.id == category.id);

            return CheckboxListTile(
              title: Text(category.name),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (isSelected)
                    _transactionPagingService.selectedCategories.remove(category);
                  else
                    _transactionPagingService.selectedCategories.add(category);
                  _transactionPagingService.dispatchRefresh();
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}