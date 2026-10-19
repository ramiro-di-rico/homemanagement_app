import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/extensions/hex_color_extension.dart';

import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  CategoryRepository _categoryRepository = GetIt.I<CategoryRepository>();
  TextEditingController _categoryNameController = TextEditingController();
  Color pickerColor = Colors.red;
  String? _nameError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: _categoryNameController,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
            decoration: InputDecoration(
              labelText: 'Category name',
              border: OutlineInputBorder(),
              errorText: _nameError,
            ),
          ),
        ),
        SizedBox(width: 20),
        SizedBox(
          width: 130,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(pickerColor),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: const EdgeInsets.all(0),
                    contentPadding: const EdgeInsets.all(0),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (color) {
                          setState(() {
                            pickerColor = color;
                          });
                        },
                        colorPickerWidth: 300,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: true,
                        displayThumbColor: true,
                        pickerAreaBorderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                        hexInputBar: true,
                      ),
                    ),
                  );
                },
              );
            },
            child: Text(
              'Pick a color',
              style: TextStyle(
                color: pickerColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () async {
            // Active and measurable, so the category shows up when adding a
            // transaction. The server ignores both flags on create.
            var category = CategoryModel(0, 0, _categoryNameController.text,
                'empty', true, true, pickerColor.toHex());
            try {
              await _categoryRepository.add(category);
              if (mounted) Navigator.pop(context);
            } on CategoryNameTakenException {
              if (!mounted) return;
              setState(() =>
                  _nameError = AppLocalizations.of(context)!.categoryNameTaken);
            }
          },
          child: Text('Add'),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
