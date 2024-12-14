import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../models/reminder.dart';
import '../../../../services/repositories/reminder_repository.dart';
import 'add_reminder_sheet_desktop.dart';

class ReminderListView extends StatefulWidget {
  @override
  _ReminderListViewState createState() => _ReminderListViewState();
}

class _ReminderListViewState extends State<ReminderListView> {
  final ReminderRepository _reminderRepository = GetIt.instance<ReminderRepository>();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _reminderRepository.addListener(_loadReminders);
  }

  @override
  void dispose() {
    _reminderRepository.removeListener(_loadReminders);
    super.dispose();
  }

  Future<void> _loadReminders() async {
    final reminders = await _reminderRepository.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  void _showReminderSheet({Reminder? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: ReminderSheet(reminder: reminder),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text('Reminders'),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showReminderSheet(),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: 330,
            child: RefreshIndicator(
              onRefresh: _loadReminders,
              child: ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return ListTile(
                    title: Text(reminder.title),
                    subtitle: Text(reminder.frequency.toString()),
                    onTap: () => _showReminderSheet(reminder: reminder),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}