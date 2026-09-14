import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/reminder_repository.dart';
import 'package:home_management_app/domain/models/reminder.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'notification_preferences_widget.dart';
import 'reminders_list_content.dart';

class RemindersDesktopView extends StatefulWidget {
  static const String fullPath = '/home_screen/reminders';
  static const String path = '/reminders';

  const RemindersDesktopView({super.key});

  @override
  State<RemindersDesktopView> createState() => _RemindersDesktopViewState();
}

class _RemindersDesktopViewState extends State<RemindersDesktopView> {
  final ReminderRepository _reminderRepository =
      GetIt.instance<ReminderRepository>();

  @override
  void initState() {
    super.initState();
    _reminderRepository.addListener(_onRepositoryChanged);
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final title = localizations?.reminders ?? 'Reminders';
    final reminders = _reminderRepository.reminders;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: const ReminderListContent(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSummaryCard(context, reminders),
                            const SizedBox(height: 16),
                            const NotificationPreferencesWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCard(context, reminders),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 500,
                      child: const ReminderListContent(),
                    ),
                    const SizedBox(height: 16),
                    const NotificationPreferencesWidget(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<Reminder> reminders) {
    final total = reminders.length;
    final completed = reminders.where((r) => r.isCompleted).length;
    final now = DateTime.now();
    final snoozed = reminders
        .where((r) =>
            !r.isCompleted &&
            r.snoozedUntil != null &&
            r.snoozedUntil!.isAfter(now))
        .length;
    final pending = reminders
        .where((r) =>
            !r.isCompleted &&
            (r.snoozedUntil == null || !r.snoozedUntil!.isAfter(now)))
        .length;

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Reminders Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Pending',
                    value: pending.toString(),
                    icon: Icons.pending_actions,
                    color: Colors.amber[700] ?? Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Snoozed',
                    value: snoozed.toString(),
                    icon: Icons.snooze,
                    color: Colors.purple[300] ?? Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Completed',
                    value: completed.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total',
                    value: total.toString(),
                    icon: Icons.list_alt,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
