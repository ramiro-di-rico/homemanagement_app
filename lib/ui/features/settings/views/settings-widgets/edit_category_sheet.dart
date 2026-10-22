import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/ui/core/extensions/hex_color_extension.dart';

import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/sources/category_data_source.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
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
  Color pickerColor = Colors.red;
  String? _nameError;
  bool _saving = false;

  /// Saves an edited copy. The category the list shows is not touched, so a save
  /// that fails (or a name that is taken) leaves the list showing what is stored.
  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final original = widget.category;
    final edited = CategoryModel(
        original.id,
        original.userId,
        _categoryNameController.text,
        original.icon,
        original.measurable,
        original.isActive,
        pickerColor.toHex());
    try {
      await _categoryRepository.update(edited);
      if (mounted) Navigator.pop(context);
    } on CategoryNameTakenException {
      if (!mounted) return;
      setState(() =>
          _nameError = AppLocalizations.of(context)!.categoryNameTaken);
    } on LocalWriteFailedException {
      // The "not saved" notice is showing. Keep the sheet and the typed name.
    } catch (error, stackTrace) {
      // Online, a failed request ends up here. Keep the sheet so it can be retried.
      developer.log('Could not update the category',
          name: 'category-sheet', error: error, stackTrace: stackTrace);
      GetIt.I<NotifierService>().notifyChangeNotSaved();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
          // Off while saving, so a double click can't send the change twice.
          onPressed: _saving ? null : _submit,
          child: Text('Update'),
        ),
      ],
    );
  }
}
