import 'package:flutter/material.dart';
import 'package:home_management_app/extensions/context_extensions.dart';

class DropdownComponent extends StatefulWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String currentValue;
  final bool isExpanded;

  DropdownComponent(
      {required this.items,
      required this.onChanged,
      required this.currentValue,
      this.isExpanded = false});

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
      onChanged: onValueChanged,
      isExpanded: widget.isExpanded,
      style: TextStyle(
          color: context.isDarkMode() ? Colors.white : Colors.black,
          fontSize: 16,
          overflow: TextOverflow.ellipsis),
    );
  }

  onValueChanged(String? value) {
    setState(() {
      this.value = value;
      this.widget.onChanged.call(value!);
    });
  }
}
