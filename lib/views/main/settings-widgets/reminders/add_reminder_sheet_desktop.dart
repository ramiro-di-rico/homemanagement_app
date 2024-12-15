import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../models/reminder.dart';
import '../../../../services/repositories/reminder_repository.dart';

class ReminderSheet extends StatefulWidget {
  final Reminder? reminder;

  ReminderSheet({this.reminder});

  @override
  _ReminderSheetState createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  final _titleController = TextEditingController();
  final ReminderRepository _reminderRepository =
      GetIt.instance<ReminderRepository>();
  Frequency? _selectedFrequency = Frequency.daily;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _selectedFrequency = widget.reminder!.frequency;
      _startDate = widget.reminder!.startDate;
      _endDate = widget.reminder!.endDate;
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty) {
      _showErrorDialog('Please enter a title');
      return;
    }

    if (_startDate == null) {
      _showErrorDialog('Please enter a start date');
      return;
    }

    final reminder = Reminder(
      widget.reminder?.id ?? 0,
      _titleController.text,
      widget.reminder?.startDate ?? DateTime.now(),
      widget.reminder?.endDate,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                width: 300,
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
                items: Frequency.values
                    .map<DropdownMenuItem<Frequency>>((Frequency value) {
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
              SizedBox(width: 20),
              SizedBox(
                width: 240,
                child: DateTimeField(
                  decoration: InputDecoration(
                    label: Text('Start Date'),
                    icon: Icon(Icons.date_range),
                  ),
                  format: DateFormat("dd MMM yyyy  HH:mm"),
                  validator: (value) {
                    if (value == null) {
                      return 'Please enter a start date';
                    }
                    return null;
                  },
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100))
                        .then((DateTime? date) async {
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    });
                  },
                  onChanged: (date) {
                    setState(() {
                      _startDate = date;
                    });
                  },
                  resetIcon: Icon(Icons.clear),
                  initialValue: widget.reminder?.startDate,
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 240,
                child: DateTimeField(
                  decoration: InputDecoration(
                    label: Text('End Date'),
                    icon: Icon(Icons.date_range),
                  ),
                  format: DateFormat("dd MMM yyyy  HH:mm"),
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100))
                        .then((DateTime? date) async {
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    });
                  },
                  onChanged: (date) {
                    setState(() {
                      _endDate = date;
                    });
                  },
                  resetIcon: Icon(Icons.clear),
                  initialValue: widget.reminder?.endDate,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: _saveReminder,
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
