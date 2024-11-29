import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/extensions/hex_color_extension.dart';

import '../../../models/category.dart';
import '../../../services/repositories/category.repository.dart';

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

  @override
  void initState() {
    pickerColor = widget.category.color.fromHex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _categoryNameController.text = widget.category.name;
    return Row(
      children: [
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(
              labelText: 'Category name',
              border: OutlineInputBorder(),
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
          onPressed: () {
            widget.category.name = _categoryNameController.text;
            widget.category.color = pickerColor.toHex();
            _categoryRepository.update(widget.category);
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
