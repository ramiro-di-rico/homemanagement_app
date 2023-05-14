import 'package:flutter/material.dart';
import 'package:home_management_app/models/notification.dart';
import 'package:home_management_app/services/notification.service.dart';

class NotificationRepository extends ChangeNotifier {
  List<NotificationModel> notifications = [];
  NotificationService notificationService;
  NotificationRepository({required this.notificationService});

  Future load() async {
    var result = await this.notificationService.fetch();
    notifications.addAll(result);
    notifyListeners();
  }

  Future update() async {
    notifyListeners();
  }

  Future remove(NotificationModel notificationModel) async {
    notifications.remove(notificationModel);
    notifyListeners();
  }

  Future dismiss(NotificationModel notificationModel) async {
    notificationModel.dismissed = true;
    notifyListeners();
  }
}
