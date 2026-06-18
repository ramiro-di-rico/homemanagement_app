import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:home_management_app/domain/models/reminder.dart';
import 'package:home_management_app/data/repositories/reminder_repository.dart';
import 'add_reminder_sheet_desktop.dart';

class ReminderListContent extends StatefulWidget {
  const ReminderListContent({super.key});

  @override
  State<ReminderListContent> createState() => _ReminderListContentState();
}

class _ReminderListContentState extends State<ReminderListContent> {
  final ReminderRepository _reminderRepository =
      GetIt.instance<ReminderRepository>();

  @override
  void initState() {
    super.initState();
    _reminderRepository.addListener(_onRepositoryChanged);
    _reminderRepository.getReminders();
  }

  @override
  void dispose() {
    _reminderRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    await _reminderRepository.getReminders(forceRefresh: true);
  }

  Future<void> _toggleCompletion(Reminder reminder, bool isCompleted) async {
    final updatedReminder = Reminder(
      reminder.id,
      reminder.title,
      reminder.startDate,
      reminder.endDate,
      reminder.frequency,
      reminder.notifyByEmail,
      isCompleted,
    );
    await _reminderRepository.updateReminder(reminder.id, updatedReminder);
  }

  void _showReminderSheet({Reminder? reminder}) {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(
        maxHeight: 1000,
        maxWidth: 600,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: 240,
            width: 800,
            child: ReminderSheet(reminder: reminder),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = _reminderRepository.reminders;
    final isLoading = _reminderRepository.isLoading;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            child: ListTile(
              title: const Text('Reminders'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Mark all as completed',
                    child: IconButton(
                      icon: const Icon(Icons.done_all),
                      onPressed: () async {
                        await _reminderRepository.setAllCompleted(true);
                      },
                    ),
                  ),
                  Tooltip(
                    message: 'Mark all as not completed',
                    child: IconButton(
                      icon: const Icon(Icons.undo),
                      onPressed: () async {
                        await _reminderRepository.setAllCompleted(false);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showReminderSheet(),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (reminders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No reminders found'),
              ),
            )
          else
            for (final reminder in reminders)
              Card(
                child: ListTile(
                  leading: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) =>
                        _toggleCompletion(reminder, value ?? false),
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: reminder.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  trailing: Text(reminder.frequencyString),
                  onTap: () => _showReminderSheet(reminder: reminder),
                ),
              ),
        ],
      ),
    );
  }
}
