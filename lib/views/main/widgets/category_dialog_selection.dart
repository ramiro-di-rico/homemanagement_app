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
  bool allSelected = false;

  @override
  Widget build(BuildContext context) {
    allSelected = _transactionPagingService.selectedCategories.length == _categoryRepository.categories.length;
    return AlertDialog(
      title: Text('Select categories'),
      content: SizedBox(
        height: 400,
        width: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CheckboxListTile(
                  value: allSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _transactionPagingService.selectedCategories = List.from(_categoryRepository.categories);
                      } else {
                        _transactionPagingService.selectedCategories.clear();
                      }
                      _transactionPagingService.dispatchRefresh();
                    });
                  },
                  title: Text('Select All'),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 330,
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
          ],
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