import 'package:flutter/material.dart';

class DropdownComponent extends StatefulWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String currentValue;

  DropdownComponent(
      {required this.items,
      required this.onChanged,
      required this.currentValue});

  @override
  _DropdownComponentState createState() => _DropdownComponentState();
}

class _DropdownComponentState extends State<DropdownComponent> {
  String? value;

  @override
  void initState() {
    super.initState();
    this.value = widget.currentValue.isNotEmpty
        ? widget.currentValue
        : this.widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: value,
        items: this
            .widget
            .items
            .map(
              (e) => DropdownMenuItem<String>(
                child: Text(e),
                value: e,
              ),
            )
            .toList(),
        onChanged: onValueChanged);
  }

  onValueChanged(String? value) {
    setState(() {
      this.value = value;
      this.widget.onChanged.call(value!);
    });
  }
}
