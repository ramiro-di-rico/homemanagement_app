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
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
                children: [
                  Text('Active', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 30),
                  Text('Can be measured', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 30),
                  Text('Name', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      //Navigator.pushNamed(context, '/add-category');
                    },
                    icon: Icon(Icons.add),
                  ),
                ]
            ),
          )
        ),
        Expanded(
          child: RefreshIndicator(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categoryRepository.categories.length,
                itemBuilder: (context, index) {
                  var category = _categoryRepository.categories[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Checkbox(value: category.isActive, onChanged: (value) {}),
                          SizedBox(width: 50),
                          Checkbox(value: category.measurable, onChanged: (value) {}),
                          SizedBox(width: 140),
                          Expanded(
                            child: Text(
                                category.name,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            flex: 1,
                          ),
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
                    ),
                  );
                },
              ),
              onRefresh: () async {
                await _categoryRepository.load();
              }
          ),
        ),
      ],
    );
  }
}
