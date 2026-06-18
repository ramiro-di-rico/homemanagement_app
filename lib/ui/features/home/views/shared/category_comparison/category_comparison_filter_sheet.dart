import 'package:flutter/material.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

class CategoryComparisonFilterSheet extends StatefulWidget {
  final DateTime initialReferenceDate;
  final int initialTake;
  final Function(DateTime, int) onApply;

  const CategoryComparisonFilterSheet({
    super.key,
    required this.initialReferenceDate,
    required this.initialTake,
    required this.onApply,
  });

  @override
  State<CategoryComparisonFilterSheet> createState() =>
      _CategoryComparisonFilterSheetState();
}

class _CategoryComparisonFilterSheetState
    extends State<CategoryComparisonFilterSheet> {
  late DateTime referenceDate;
  late int take;

  @override
  void initState() {
    super.initState();
    referenceDate = widget.initialReferenceDate;
    take = widget.initialTake;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(localizations.referenceDate),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: referenceDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    referenceDate = picked;
                  });
                }
              },
            ),
            subtitle: Text('${referenceDate.toLocal()}'.split(' ')[0]),
          ),
          ListTile(
            title: Text(localizations.itemsToTake),
            trailing: DropdownButton<int>(
              value: take,
              onChanged: (int? newValue) {
                setState(() {
                  take = newValue!;
                });
              },
              items: <int>[3, 5, 10, 20]
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
              widget.onApply(referenceDate, take);
              Navigator.pop(context);
            },
            child: Text(localizations.apply),
          ),
        ],
      ),
    );
  }
}
