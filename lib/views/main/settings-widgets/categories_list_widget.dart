import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/repositories/category.repository.dart';

class CategoriesListWidget extends StatefulWidget {
  const CategoriesListWidget({super.key});

  @override
  State<CategoriesListWidget> createState() => _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends State<CategoriesListWidget> {

  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _categoryRepository.categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Row(
                children: [
                  Checkbox(value: true, onChanged: (value) {}),
                  Checkbox(value: false, onChanged: (value) {}),
                  Expanded(child: Text(_categoryRepository.categories[index].name), flex: 1,),
                  MenuAnchor(
                      menuChildren: [
                        MenuItemButton(
                          child: Text('Edit'),
                          onPressed: () {
                          },
                        ),
                        MenuItemButton(
                          child: Text('Delete'),
                          onPressed: () {
                            //_categoryRepository.delete(_categoryRepository.categories[index]);
                          },
                        ),
                      ],
                    builder: (BuildContext context, MenuController controller,
                        Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Show menu',
                      );
                    },
                  ),
                ],
              ),
              onTap: () {

              }
            );
          },
        ),
        onRefresh: () async {
          await _categoryRepository.load();
        }
    );
  }
}
