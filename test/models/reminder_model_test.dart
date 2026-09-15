import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/domain/models/reminder.dart';

void main() {
  group('Reminder model JSON compatibility', () {
    test('toJson omits endDate and snoozedUntil when they are null', () {
      final reminder = Reminder(
        1,
        'Pay rent',
        DateTime.utc(2026, 8, 16, 12, 0),
        null,
        Frequency.monthly,
        true,
        false,
      );

      final json = reminder.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Pay rent');
      expect(json['startDate'], '2026-08-16T12:00:00.000Z');
      expect(json['frequency'], Frequency.monthly.index);
      expect(json['notifyByEmail'], true);
      expect(json['isCompleted'], false);
      expect(json.containsKey('endDate'), isFalse);
      expect(json.containsKey('snoozedUntil'), isFalse);
    });

    test('toJson includes endDate and snoozedUntil when provided', () {
      final reminder = Reminder(
        2,
        'Renew insurance',
        DateTime.utc(2026, 8, 16, 12, 0),
        DateTime.utc(2026, 9, 16, 12, 0),
        Frequency.yearly,
        false,
        true,
        DateTime.utc(2026, 8, 20, 12, 0),
      );

      final json = reminder.toJson();

      expect(json['id'], 2);
      expect(json['title'], 'Renew insurance');
      expect(json['startDate'], '2026-08-16T12:00:00.000Z');
      expect(json['endDate'], '2026-09-16T12:00:00.000Z');
      expect(json['frequency'], Frequency.yearly.index);
      expect(json['notifyByEmail'], false);
      expect(json['isCompleted'], true);
      expect(json['snoozedUntil'], '2026-08-20T12:00:00.000Z');
    });

    test('fromJson deserializes correctly without endDate or snoozedUntil', () {
      final json = {
        'id': 3,
        'title': 'Call dentist',
        'startDate': '2026-08-16T10:00:00.000Z',
        'frequency': 0,
        'notifyByEmail': false,
        'isCompleted': false,
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.id, 3);
      expect(reminder.title, 'Call dentist');
      expect(reminder.startDate, DateTime.parse('2026-08-16T10:00:00.000Z'));
      expect(reminder.endDate, isNull);
      expect(reminder.frequency, Frequency.daily);
      expect(reminder.notifyByEmail, false);
      expect(reminder.isCompleted, false);
      expect(reminder.snoozedUntil, isNull);
    });

    test('fromJson handles explicit null or empty string for endDate and snoozedUntil', () {
      final json = {
        'id': 4,
        'title': 'Water plants',
        'startDate': '2026-08-16T10:00:00.000Z',
        'endDate': '',
        'frequency': 4,
        'notifyByEmail': true,
        'isCompleted': false,
        'snoozedUntil': null,
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.id, 4);
      expect(reminder.title, 'Water plants');
      expect(reminder.endDate, isNull);
      expect(reminder.frequency, Frequency.workDays);
      expect(reminder.snoozedUntil, isNull);
    });

    test('fromJson deserializes weekly frequency correctly', () {
      final json = {
        'id': 5,
        'title': 'Weekly sync',
        'startDate': '2026-08-16T10:00:00.000Z',
        'frequency': 1,
        'notifyByEmail': true,
        'isCompleted': false,
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.frequency, Frequency.weekly);
    });

    test('frequencyString returns expected string representation', () {
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, false).frequencyString, 'Daily');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.weekly, false, false).frequencyString, 'Weekly');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.monthly, false, false).frequencyString, 'Monthly');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.yearly, false, false).frequencyString, 'Yearly');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.workDays, false, false).frequencyString, 'WorkDays');
    });

    test('isSnoozed returns true only when not completed and snoozedUntil is in future', () {
      final futureDate = DateTime.now().add(const Duration(days: 2));
      final pastDate = DateTime.now().subtract(const Duration(days: 2));

      final snoozedActive = Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, false, futureDate);
      expect(snoozedActive.isSnoozed, isTrue);

      final snoozedCompleted = Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, true, futureDate);
      expect(snoozedCompleted.isSnoozed, isFalse);

      final expiredSnooze = Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, false, pastDate);
      expect(expiredSnooze.isSnoozed, isFalse);

      final noSnooze = Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, false, null);
      expect(noSnooze.isSnoozed, isFalse);
    });

    test('copyWith creates a new instance with updated properties', () {
      final original = Reminder(
        1,
        'Original',
        DateTime.utc(2026, 8, 1),
        DateTime.utc(2026, 8, 10),
        Frequency.daily,
        false,
        false,
        DateTime.utc(2026, 8, 5),
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
        clearSnoozedUntil: true,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, isTrue);
      expect(updated.snoozedUntil, isNull);
      expect(updated.startDate, original.startDate);
      expect(updated.endDate, original.endDate);
      expect(updated.frequency, original.frequency);
    });

    test('fromJson correctly maps all backend ReminderFrequency indices', () {
      final frequencies = {
        0: Frequency.daily,
        1: Frequency.weekly,
        2: Frequency.monthly,
        3: Frequency.yearly,
        4: Frequency.workDays,
      };

      for (final entry in frequencies.entries) {
        final reminder = Reminder.fromJson({
          'id': entry.key + 1,
          'title': 'Test',
          'startDate': '2026-08-16T10:00:00.000Z',
          'frequency': entry.key,
        });
        expect(reminder.frequency, entry.value);
        expect(reminder.frequency.index, entry.key);
      }

      // Out of bounds falls back gracefully to daily without crashing
      final unknown = Reminder.fromJson({
        'id': 99,
        'title': 'Unknown',
        'startDate': '2026-08-16T10:00:00.000Z',
        'frequency': 999,
      });
      expect(unknown.frequency, Frequency.daily);
    });

    test('fromJson handles null title, string id, and missing boolean fields', () {
      final reminder = Reminder.fromJson({
        'id': '123',
        'title': null,
        'startDate': '2026-08-16T10:00:00.000Z',
        'frequency': 2,
      });

      expect(reminder.id, 123);
      expect(reminder.title, '');
      expect(reminder.frequency, Frequency.monthly);
      expect(reminder.notifyByEmail, isFalse);
      expect(reminder.isCompleted, isFalse);
      expect(reminder.snoozedUntil, isNull);
      expect(reminder.endDate, isNull);
    });
  });
}
