import 'package:flutter/material.dart';

class SyncOptionsWidget extends StatefulWidget {
  SyncOptionsWidget({Key key}) : super(key: key);

  @override
  _SyncOptionsWidgetState createState() => _SyncOptionsWidgetState();
}

class _SyncOptionsWidgetState extends State<SyncOptionsWidget> {
  bool syncEnabled = false;

  onSyncChanged(bool value) {
    setState(() {
      this.syncEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeData.dark().bottomAppBarColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: syncEnabled, onChanged: onSyncChanged),
              Text('Sync Options')
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text('By enabling this option ...'),
          )
        ],
      ),
    );
  }
}
