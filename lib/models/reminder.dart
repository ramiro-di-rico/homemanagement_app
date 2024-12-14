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

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      json['id'] as int,
      json['title'] as String,
      DateTime.parse(json['startDate'] as String),
      json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      Frequency.values.firstWhere((e) => e.toString().split('.').last == json['frequency']),
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