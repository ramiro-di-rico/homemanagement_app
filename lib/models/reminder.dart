enum Frequency {
  daily,
  monthly,
  yearly,
}

class Reminder {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final Frequency frequency;
  final bool notifyByEmail;

  Reminder(this.id, this.title, this.startDate, this.endDate, this.frequency, this.notifyByEmail);

  String get frequencyString {
    switch (frequency) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.yearly:
        return 'Yearly';
    }
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      json['id'] as int,
      json['title'] as String,
      DateTime.parse(json['startDate'] as String),
      json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      Frequency.values.firstWhere((e) => e.index == json['frequency']),
      json['notifyByEmail'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'frequency': frequency.toString().split('.').last,
      'notifyByEmail': notifyByEmail,
    };
  }
}