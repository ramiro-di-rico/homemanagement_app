enum BackupFrequency {
  weekly,
  monthly,
}

BackupFrequency backupFrequencyFromJson(dynamic value) {
  final int? intValue = value is int ? value : int.tryParse(value?.toString() ?? '');

  return intValue == BackupFrequency.monthly.index
      ? BackupFrequency.monthly
      : BackupFrequency.weekly;
}

extension BackupFrequencyMapper on BackupFrequency {
  int get value => index;

  String get label => switch (this) {
        BackupFrequency.weekly => 'Weekly',
        BackupFrequency.monthly => 'Monthly',
      };

  static BackupFrequency fromValue(int? value) {
    return value == BackupFrequency.monthly.index
        ? BackupFrequency.monthly
        : BackupFrequency.weekly;
  }
}

class UserSettings {
  String csvDelimiter;
  String currency;
  BackupFrequency backupFrequency;

  UserSettings(this.csvDelimiter, this.currency, this.backupFrequency);

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    var csvDelimiter = json['csvDelimiter'] ?? '';
    var currency = json['currency'] ?? '';
    var backupFrequency = backupFrequencyFromJson(json['backupFrequency']);

    return UserSettings(csvDelimiter, currency, backupFrequency);
  }

  Map toJson() => {
    'csvDelimiter': csvDelimiter,
    'currency': currency,
    'backupFrequency': backupFrequency.value,
  };
}
