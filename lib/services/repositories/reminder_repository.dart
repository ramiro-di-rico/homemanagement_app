import 'package:flutter/material.dart';
import 'package:home_management_app/services/infra/error_notifier_service.dart';
import '../../models/reminder.dart';
import '../endpoints/reminder_service.dart';

class ReminderRepository extends ChangeNotifier {
  final ReminderService _reminderService;
  final NotifierService _notifierService;
  List<Reminder> _cachedReminders = [];

  ReminderRepository(this._reminderService, this._notifierService);

  Future<List<Reminder>> getReminders() async {
    if (_cachedReminders.isEmpty) {
      _cachedReminders = await _reminderService.getReminders();
      notifyListeners();
    }
    return _cachedReminders;
  }

  Future addReminder(Reminder reminder) async {
    try {
      final newReminder = await _reminderService.addReminder(reminder);
      _cachedReminders.add(newReminder);
      notifyListeners();
      _notifierService.notify('Reminder added');
    } on Exception catch (e) {
      _notifierService.notify(e.toString(), isError: true);
    }
  }

  Future updateReminder(int id, Reminder reminder) async {
    try {
      final updatedReminder = await _reminderService.updateReminder(id, reminder);
      final index = _cachedReminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _cachedReminders[index] = updatedReminder;
        notifyListeners();
      }
      _notifierService.notify('Reminder updated');
    } on Exception catch (e) {
      _notifierService.notify(e.toString(), isError: true);
    }
  }

  Future deleteReminder(int id) async {
    try {
      await _reminderService.deleteReminder(id.toString());
      _cachedReminders.removeWhere((r) => r.id == id);
      notifyListeners();
      _notifierService.notify('Reminder deleted');
    } on Exception catch (e) {
      _notifierService.notify(e.toString(), isError: true);
    }
  }
}