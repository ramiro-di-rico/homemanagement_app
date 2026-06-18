import 'package:flutter/material.dart';
import 'reminders_list_content.dart';

class ReminderListView extends StatelessWidget {
  const ReminderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReminderListContent(),
    );
  }
}
