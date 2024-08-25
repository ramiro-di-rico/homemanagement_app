import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/views/main/settings-widgets/add_category_sheet.dart';

import '../../../services/repositories/category.repository.dart';
import '../../mixins/notifier_mixin.dart';
import 'edit_category_sheet.dart';

class CategoriesListWidget extends StatefulWidget {
  const CategoriesListWidget({super.key});

  @override
  State<CategoriesListWidget> createState() => _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends State<CategoriesListWidget> with NotifierMixin {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();

  @override
  void initState() {
    super.initState();
    _categoryRepository.addListener(refreshList);
  }

  @override
  void dispose() {
    _categoryRepository.removeListener(refreshList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                      showModalBottomSheet(
                          context: context,
                          constraints: BoxConstraints(
                            maxHeight: 1000,
                            maxWidth: 500,
                          ),
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0))),
                          builder: (context) {
                            return SizedBox(
                              height: 100,
                              child: AnimatedPadding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom
                                ),
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.decelerate,
                                child: AddCategorySheet()
                              ),
                            );
                          }
                      );
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
                                  leadingIcon: Icon(Icons.edit, color: Colors.blueAccent),
                                  child: Text('Edit', style: TextStyle(color: Colors.blueAccent)),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        constraints: BoxConstraints(
                                          maxHeight: 1000,
                                          maxWidth: 500,
                                        ),
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(25.0))),
                                        builder: (context) {
                                          return SizedBox(
                                            height: 100,
                                            child: AnimatedPadding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context).viewInsets.bottom
                                              ),
                                              duration: const Duration(milliseconds: 100),
                                              curve: Curves.decelerate,
                                              child: EditCategorySheet(category: category)
                                            ),
                                          );
                                        }
                                    );
                                  },
                                ),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.delete, color: Colors.redAccent),
                                  child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                  onPressed: () {
                                    _categoryRepository.delete(_categoryRepository.categories[index]);
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

  void refreshList() {
    setState(() {});
  }
}
