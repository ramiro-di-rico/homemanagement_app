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

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        widget.reminder!.id,
        _titleController.text,
        widget.reminder!.startDate,
        widget.reminder!.endDate,
        widget.reminder!.frequency,
        widget.reminder!.notifyByEmail,
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
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
              ),
              SizedBox(width: 10),

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