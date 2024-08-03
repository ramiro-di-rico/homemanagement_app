import 'package:home_management_app/models/category.dart';
import 'package:home_management_app/services/infra/error_notifier_service.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';
import 'dart:convert';

import 'notification.service.dart';

class CategoryService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  NotifierService notifierService;

  CategoryService(
      {required this.authenticationService,
        required this.apiServiceFactory,
        required this.notifierService});

  Future<List<CategoryModel>> fetch() async {
    var data = await this.apiServiceFactory.fetchList('category/v3');
    var result = data.map((e) => CategoryModel.fromJson(e)).toList();
    return result;
  }

  Future<CategoryModel> add(CategoryModel category) async {
    var result = await this.apiServiceFactory.postWithReturn('category/v3', json.encode(category));
    notifierService.notify('Category ${category.name} added');
    return CategoryModel.fromJson(result);
  }

  Future update(CategoryModel category) async {
    await this.apiServiceFactory.apiPut('category/v3', category.toJson());
    notifierService.notify('Category ${category.name} updated');
  }

  Future delete(CategoryModel category) async {
    await this.apiServiceFactory.apiDelete('category/v3/', category.id.toString());
    notifierService.notify('Category ${category.name} deleted');
  }
}
