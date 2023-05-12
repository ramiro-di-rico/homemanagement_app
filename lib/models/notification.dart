class NotificationModel {
  final int id, reminderId;
  String title, description;
  int dueDay;
  bool dismissed;

  NotificationModel(this.id, this.reminderId, this.title, this.description,
      this.dismissed, this.dueDay);

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      json['id'],
      json['reminderId'],
      json['title'],
      json['description'] ?? '',
      json['dismissed'],
      json['dueDay'],
    );
  }
}
