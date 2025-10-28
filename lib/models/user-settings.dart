class UserSettings{
  String csvDelimiter;

  UserSettings(this.csvDelimiter);

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    var csvDelimiter = json['csvDelimiter'] ?? '';

    return UserSettings(csvDelimiter);
  }

  Map toJson() => {
    'csvDelimiter': this.csvDelimiter
  };
}