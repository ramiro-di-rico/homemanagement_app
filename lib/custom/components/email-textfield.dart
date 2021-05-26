import 'package:flutter/material.dart';

class EmailTextField extends TextField{

  final Function(String) onTextChanged;
  final TextEditingController editingController;

  EmailTextField({this.onTextChanged, this.editingController});

  @override
  TextInputType get keyboardType => TextInputType.emailAddress;

  @override
  TextAlign get textAlign => TextAlign.center;

  @override
  InputDecoration get decoration => InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        labelText: 'Email',
        prefixIcon: Icon(Icons.email));
  
  @override
  get onChanged => onTextChanged;

  @override
  TextEditingController get controller => editingController;
}