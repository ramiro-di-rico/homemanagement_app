import 'package:flutter/material.dart';

class DropdownComponent extends StatefulWidget {

  List<String> items;
  Function(String) onChanged;

  DropdownComponent({@required this.items, @required this.onChanged});

  @override
  _DropdownComponentState createState() => _DropdownComponentState();
}

class _DropdownComponentState extends State<DropdownComponent> {

  String value;

  @override
  void initState() {
    super.initState();
    this.value = this.widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      items: this.widget.items
          .map(
            (e) => DropdownMenuItem<String>(
              child: Text(e),
              value: e,
            ),
          )
          .toList(),
      onChanged: onValueChanged);
  }

  onValueChanged(String value){
    setState(() {
      this.value = value;
      this.widget.onChanged.call(value);
    });    
  }
}
