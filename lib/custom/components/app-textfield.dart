import 'package:flutter/material.dart';

class AppTextField extends TextField {
  final String label;
  final Function(String)? onTextChanged;
  final TextEditingController? editingController;

  AppTextField(
      {required this.label, this.onTextChanged, this.editingController});

  @override
  TextInputType get keyboardType => TextInputType.name;

  @override
  TextAlign get textAlign => TextAlign.center;

  @override
  InputDecoration get decoration => InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      labelText: label);

  @override
  get onChanged => onTextChanged;

  @override
  TextEditingController get controller => editingController!;
}
