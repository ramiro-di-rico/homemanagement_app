import 'package:flutter/material.dart';

class FilterOptionsSheet extends StatefulWidget {
  final DateTime initialDateFrom;
  final DateTime initialDateTo;
  final int initialTake;
  final Function(DateTime, DateTime, int) onApply;

  FilterOptionsSheet({
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.initialTake,
    required this.onApply,
  });

  @override
  _FilterOptionsSheetState createState() => _FilterOptionsSheetState();
}

class _FilterOptionsSheetState extends State<FilterOptionsSheet> {
  late DateTime dateFrom;
  late DateTime dateTo;
  late int take;

  @override
  void initState() {
    super.initState();
    dateFrom = widget.initialDateFrom;
    dateTo = widget.initialDateTo;
    take = widget.initialTake;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Date From'),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: dateFrom,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    dateFrom = picked;
                  });
                }
              },
            ),
            subtitle: Text('${dateFrom.toLocal()}'.split(' ')[0]),
          ),
          ListTile(
            title: Text('Date To'),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: dateTo,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    dateTo = picked;
                  });
                }
              },
            ),
            subtitle: Text('${dateTo.toLocal()}'.split(' ')[0]),
          ),
          ListTile(
            title: Text('Items to Take'),
            trailing: DropdownButton<int>(
              value: take,
              onChanged: (int? newValue) {
                setState(() {
                  take = newValue!;
                });
              },
              items: <int>[1, 3, 5, 10, 20]
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onApply(dateFrom, dateTo, take);
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}