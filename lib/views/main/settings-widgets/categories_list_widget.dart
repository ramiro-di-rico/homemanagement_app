import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/hex_color_extension.dart';
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
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withAlpha(50),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
                children: [
                  SizedBox(width: 60, child: Text('Active', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  SizedBox(width: 20),
                  SizedBox(width: 150, child: Text('Can be measured', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  SizedBox(width: 20),
                  Expanded(child: Text('Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
                  final backgroundColor = category.color.fromHex();
                  final contentColor = _getContentColor(backgroundColor);
                  return Card(
                    color: backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 60,
                              child: Checkbox(
                                  value: category.isActive,
                                  checkColor: backgroundColor,
                                  activeColor: contentColor,
                                  side: BorderSide(color: contentColor, width: 2),
                                  onChanged: (value) {}
                              )
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                              width: 150,
                              child: Checkbox(
                                  value: category.measurable,
                                  checkColor: backgroundColor,
                                  activeColor: contentColor,
                                  side: BorderSide(color: contentColor, width: 2),
                                  onChanged: (value) {}
                              )
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                                category.name,
                              style: TextStyle(
                                fontSize: 18,
                                color: contentColor,
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
                                icon: Icon(Icons.more_vert, color: contentColor),
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

  Color _getContentColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void refreshList() {
    setState(() {});
  }
}
