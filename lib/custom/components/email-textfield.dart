import 'package:flutter/material.dart';

class EmailTextField extends StatefulWidget {
  final Function(String) onTextChanged;
  final TextEditingController editingController;
  final bool enableEmailField;

  EmailTextField(
      {this.onTextChanged, this.editingController, this.enableEmailField});

  @override
  _EmailTextFieldState createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        labelText: 'Email or username',
        prefixIcon: Icon(Icons.email),
      ),
      onChanged: widget.onTextChanged,
      controller: widget.editingController,
      enabled: widget.enableEmailField,
    );
  }
}
