import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/reminder_repository.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/ui/core/mixins/notifier_mixin.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  @override
  State<NotificationPreferencesWidget> createState() => _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState extends State<NotificationPreferencesWidget> with NotifierMixin {
  final ReminderRepository _reminderRepository = GetIt.instance<ReminderRepository>();
  final IdentityUserRepository _identityUserRepository = GetIt.instance<IdentityUserRepository>();

  late TextEditingController _sendTimeController;
  int _digestFrequency = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendTimeController = TextEditingController();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    final user = await _identityUserRepository.getUser();
    if (user != null) {
      setState(() {
        _digestFrequency = user.digestFrequency ?? 0;
        _sendTimeController.text = user.preferredSendTime ?? '';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _sendTimeController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    final user = _identityUserRepository.currentUser;
    if (user == null || user.id == null) return;

    await _reminderRepository.updateNotificationPreferences(
      user.id!,
      _digestFrequency,
      _sendTimeController.text.isEmpty ? null : _sendTimeController.text,
    );
    // Refresh user data to get updated preferences
    await _identityUserRepository.getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _digestFrequency,
              decoration: const InputDecoration(
                labelText: 'Digest Frequency',
                helperText: 'How often you want to receive notifications (0 for disabled)',
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Disabled')),
                DropdownMenuItem(value: 1, child: Text('Daily')),
                DropdownMenuItem(value: 7, child: Text('Weekly')),
                DropdownMenuItem(value: 30, child: Text('Monthly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _digestFrequency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sendTimeController,
              decoration: const InputDecoration(
                labelText: 'Preferred Send Time',
                hintText: 'HH:mm:ss',
                helperText: 'Time of day to send notifications',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
