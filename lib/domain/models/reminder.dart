enum Frequency {
  daily,
  weekly,
  monthly,
  yearly,
  workDays,
}

class Reminder {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final Frequency frequency;
  final bool notifyByEmail;
  final bool isCompleted;
  final DateTime? snoozedUntil;

  Reminder(
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.frequency,
    this.notifyByEmail,
    this.isCompleted, [
    this.snoozedUntil,
  ]);

  bool get isSnoozed =>
      !isCompleted && snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  Reminder copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    Frequency? frequency,
    bool? notifyByEmail,
    bool? isCompleted,
    DateTime? snoozedUntil,
    bool clearEndDate = false,
    bool clearSnoozedUntil = false,
  }) {
    return Reminder(
      id ?? this.id,
      title ?? this.title,
      startDate ?? this.startDate,
      clearEndDate ? null : (endDate ?? this.endDate),
      frequency ?? this.frequency,
      notifyByEmail ?? this.notifyByEmail,
      isCompleted ?? this.isCompleted,
      clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
    );
  }

  String get frequencyString {
    switch (frequency) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.yearly:
        return 'Yearly';
      case Frequency.workDays:
        return 'WorkDays';
    }
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      (json['title'] as String?) ?? '',
      json['startDate'] != null && json['startDate'].toString().isNotEmpty
          ? (DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now())
          : DateTime.now(),
      json['endDate'] != null && json['endDate'].toString().isNotEmpty
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      json['frequency'] is int
          ? Frequency.values.firstWhere(
              (e) => e.index == json['frequency'],
              orElse: () => Frequency.daily,
            )
          : Frequency.daily,
      json['notifyByEmail'] is bool ? json['notifyByEmail'] as bool : false,
      json['isCompleted'] is bool
          ? json['isCompleted'] as bool
          : (json['isCompleted'] == 1 || json['isCompleted'] == 'true'),
      json['snoozedUntil'] != null && json['snoozedUntil'].toString().isNotEmpty
          ? DateTime.tryParse(json['snoozedUntil'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'frequency': frequency.index,
      'notifyByEmail': notifyByEmail,
      'isCompleted': isCompleted,
    };
    if (endDate != null) {
      data['endDate'] = endDate!.toIso8601String();
    }
    if (snoozedUntil != null) {
      data['snoozedUntil'] = snoozedUntil!.toIso8601String();
    }
    return data;
  }
}
