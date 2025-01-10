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
  final ReminderRepository _reminderRepository =
      GetIt.instance<ReminderRepository>();
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
      constraints: BoxConstraints(
        maxHeight: 1000,
        maxWidth: 600,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
              height: 190,
              width: 800,
              child: ReminderSheet(reminder: reminder)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: SingleChildScrollView(
        child: SizedBox(
          height: 290,
          child: Column(
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
              RefreshIndicator(
                onRefresh: _loadReminders,
                child: ListView.builder(
                  itemCount: _reminders.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return Card(
                      child: ListTile(
                        title: Text(reminder.title),
                        trailing: Text(reminder.frequencyString),
                        onTap: () => _showReminderSheet(reminder: reminder),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
