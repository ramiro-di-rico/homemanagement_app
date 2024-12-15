import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../models/reminder.dart';
import '../../../../services/repositories/reminder_repository.dart';

class ReminderSheet extends StatefulWidget {
  final Reminder? reminder;

  ReminderSheet({this.reminder});

  @override
  _ReminderSheetState createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final ReminderRepository _reminderRepository = GetIt.instance<ReminderRepository>();
  Frequency? _selectedFrequency = Frequency.daily;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _selectedFrequency = widget.reminder!.frequency;
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        widget.reminder?.id ?? 0,
        _titleController.text,
        widget.reminder?.startDate ?? DateTime.now(),
        widget.reminder?.endDate ?? DateTime.now().add(Duration(days: 1)),
        _selectedFrequency ?? Frequency.daily,
        widget.reminder?.notifyByEmail ?? false,
      );
      if (widget.reminder == null) {
        await _reminderRepository.addReminder(reminder);
      } else {
        await _reminderRepository.updateReminder(reminder.id, reminder);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 150,
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 20),
              Text('Frequency:'),
              SizedBox(width: 5),
              DropdownButton<Frequency>(
                value: _selectedFrequency,
                onChanged: (Frequency? newValue) {
                  setState(() {
                    _selectedFrequency = newValue;
                  });
                },
                items: Frequency.values.map<DropdownMenuItem<Frequency>>((Frequency value) {
                  return DropdownMenuItem<Frequency>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [

              ElevatedButton(
                onPressed: _saveReminder,
                child: Text(widget.reminder == null ? 'Add Reminder' : 'Update Reminder'),
              ),
            ],
          )
        ],
      ),
    );
  }
}