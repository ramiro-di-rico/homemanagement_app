class NotificationModel {
  final int id;
  String title;
  bool dismissed;
  DateTime createdOn;

  NotificationModel(this.id, this.title, this.dismissed, this.createdOn);

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    var createdOn = DateTime.parse(json['createdOn']);
    return NotificationModel(
        json['id'], json['title'], json['dismissed'], createdOn);
  }
}
