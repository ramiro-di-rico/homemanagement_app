import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final Function(String) onTextChanged;
  final TextEditingController? editingController;
  final bool enablePassword;

  PasswordTextField(
      {required this.onTextChanged,
      this.editingController,
      required this.enablePassword});

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofillHints: [AutofillHints.password],
      enabled: widget.enablePassword,
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.center,
      obscureText: hidePassword,
      controller: widget.editingController,
      onChanged: widget.onTextChanged,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          labelText: 'Password',
          suffixIcon: TextButton(
            child: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: changePasswordVisibility,
          ),
          prefixIcon: Icon(Icons.vpn_key)),
    );
  }

  changePasswordVisibility() {
    setState(() {
      this.hidePassword = !this.hidePassword;
    });
  }
}
