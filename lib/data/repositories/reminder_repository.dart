import 'package:flutter/material.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/domain/models/reminder.dart';
import 'package:home_management_app/data/services/reminder_service.dart';

class ReminderRepository extends ChangeNotifier {
  final ReminderService _reminderService;
  final NotifierService _notifierService;
  List<Reminder> _cachedReminders = [];
  bool _isLoading = false;

  ReminderRepository(this._reminderService, this._notifierService);

  bool get isLoading => _isLoading;
  List<Reminder> get reminders => _cachedReminders;

  Future<List<Reminder>> getReminders({bool forceRefresh = false}) async {
    if (_cachedReminders.isEmpty || forceRefresh) {
      _isLoading = true;
      notifyListeners();
      try {
        _cachedReminders = await _reminderService.getReminders();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
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

  Future setAllCompleted(bool isCompleted) async {
    try {
      await _reminderService.setAllCompleted(isCompleted);
      _cachedReminders = _cachedReminders
          .map((r) => Reminder(r.id, r.title, r.startDate, r.endDate, r.frequency, r.notifyByEmail, isCompleted))
          .toList();
      notifyListeners();
      _notifierService.notify(isCompleted ? 'All reminders completed' : 'All reminders marked as not completed');
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