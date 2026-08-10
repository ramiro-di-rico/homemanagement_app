import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/extensions/hex_color_extension.dart';
import 'package:home_management_app/ui/features/settings/views/settings-widgets/add_category_sheet.dart';

import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';
import 'edit_category_sheet.dart';

class CategoriesListWidget extends StatefulWidget {
  const CategoriesListWidget({super.key});

  @override
  State<CategoriesListWidget> createState() => _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends State<CategoriesListWidget> with NotifierMixin {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _categoryRepository.addListener(refreshList);
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _categoryRepository.removeListener(refreshList);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCategories = _query.trim().isEmpty
        ? _categoryRepository.categories
        : _categoryRepository.categories
            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: AppLocalizations.of(context)!.searchCategories,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
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
                    itemCount: visibleCategories.length,
                    itemBuilder: (context, index) {
                  var category = visibleCategories[index];
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
                                Divider(height: 1, thickness: 1),
                                MenuItemButton(
                                  leadingIcon: Icon(Icons.delete, color: Colors.redAccent),
                                  child: Text('Delete',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    _categoryRepository.delete(category);
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
        ),
      ),
    );
  }

  Color _getContentColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void refreshList() {
    setState(() {});
  }
}
