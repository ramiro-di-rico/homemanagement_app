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
    return Container(
      height: 320,
      child: SingleChildScrollView(
        child: SizedBox(
          height: 300,
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(reminder.title),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _showReminderSheet(reminder: reminder),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(reminder.frequency.toString()),
                                Text(reminder.startDate.toString()),
                                Text(reminder.endDate?.toString() ?? ''),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                    /*return Card(
                      child: ListTile(
                        title: Text(reminder.title),
                        subtitle: Text(reminder.frequency.toString()),

                        onTap: () => _showReminderSheet(reminder: reminder),
                      ),
                    );*/
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