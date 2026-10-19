import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/extensions/hex_color_extension.dart';

import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

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
  Color pickerColor = Colors.red;
  String? _nameError;

  @override
  void initState() {
    pickerColor = widget.category.color.fromHex();
    // Set once: setting it in build would overwrite what the user typed on every rebuild.
    _categoryNameController.text = widget.category.name;
    super.initState();
  }

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
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final previousName = widget.category.name;
            final previousColor = widget.category.color;
            widget.category.name = _categoryNameController.text;
            widget.category.color = pickerColor.toHex();
            try {
              await _categoryRepository.update(widget.category);
              if (mounted) Navigator.pop(context);
            } on CategoryNameTakenException {
              // Nothing was saved, so the list must keep showing the old values.
              widget.category.name = previousName;
              widget.category.color = previousColor;
              if (!mounted) return;
              setState(() =>
                  _nameError = AppLocalizations.of(context)!.categoryNameTaken);
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
