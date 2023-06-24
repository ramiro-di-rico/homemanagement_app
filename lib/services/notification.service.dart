import 'package:home_management_app/models/notification.dart';
import 'package:home_management_app/services/authentication.service.dart';

import 'api.service.factory.dart';

class NotificationService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  NotificationService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<NotificationModel>> fetch() async {
    var data = await this.apiServiceFactory.fetchList('notification/v3/my');
    var result = data.map((e) => NotificationModel.fromJson(e)).toList();
    return result;
  }
}
