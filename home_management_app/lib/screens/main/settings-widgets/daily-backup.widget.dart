import 'package:flutter/material.dart';
import 'package:home_management_app/custom/main-card.dart';

class DailyBackupWdiget extends StatefulWidget {
  @override
  _DailyBackupWdigetState createState() => _DailyBackupWdigetState();
}

class _DailyBackupWdigetState extends State<DailyBackupWdiget> {
  bool dailyBackupEnabled = false;

  onEnableChanged(bool value) {
    setState(() {
      this.dailyBackupEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainCard(
      child: Row(             
        mainAxisAlignment: MainAxisAlignment.start,   
        children: [
          Checkbox(
            value: dailyBackupEnabled, 
            onChanged: onEnableChanged,
            activeColor: Colors.pinkAccent,
          ),
          Expanded(
            child: Text('Sync Options'),
          ),
          Expanded(
            child: FlatButton(
              shape: CircleBorder(),
              child: Icon(
                Icons.cloud_download,
                color: Colors.pinkAccent,
              ), 
              onPressed: (){

              })
          )
        ],
      ),
    );
  }
}
