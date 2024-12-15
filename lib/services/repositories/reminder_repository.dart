import 'package:flutter/material.dart';
import '../../models/reminder.dart';
import '../endpoints/reminder_service.dart';

class ReminderRepository extends ChangeNotifier {
  final ReminderService _reminderService;
  List<Reminder> _cachedReminders = [];

  ReminderRepository(this._reminderService);

  Future<List<Reminder>> getReminders() async {
    if (_cachedReminders.isEmpty) {
      _cachedReminders = await _reminderService.getReminders();
      notifyListeners();
    }
    return _cachedReminders;
  }

  Future<Reminder> addReminder(Reminder reminder) async {
    final newReminder = await _reminderService.addReminder(reminder);
    _cachedReminders.add(newReminder);
    notifyListeners();
    return newReminder;
  }

  Future<Reminder> updateReminder(int id, Reminder reminder) async {
    final updatedReminder = await _reminderService.updateReminder(id, reminder);
    final index = _cachedReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedReminders[index] = updatedReminder;
      notifyListeners();
    }
    return updatedReminder;
  }

  Future<void> deleteReminder(int id) async {
    await _reminderService.deleteReminder(id.toString());
    _cachedReminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}