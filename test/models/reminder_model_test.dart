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
        'frequency': 3,
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

    test('frequencyString returns expected string representation', () {
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.daily, false, false).frequencyString, 'Daily');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.monthly, false, false).frequencyString, 'Monthly');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.yearly, false, false).frequencyString, 'Yearly');
      expect(Reminder(1, 't', DateTime.now(), null, Frequency.workDays, false, false).frequencyString, 'WorkDays');
    });
  });
}
