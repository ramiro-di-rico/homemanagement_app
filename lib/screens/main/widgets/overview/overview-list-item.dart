import 'package:flutter/material.dart';

class OverviewListitem extends StatelessWidget {
  final String name;
  final String value;
  final String total;

  const OverviewListitem({Key key, this.name, this.value, this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(name),
      SizedBox(
        width: 50,
      ),
      Text('Count'),
      SizedBox(width: 10),
      Text(value),
      SizedBox(width: 30),
      Text(total == null ? '' : 'Amount'),
      SizedBox(width: 10),
      Text(total == null ? '' : total)
    ]);
  }
}
