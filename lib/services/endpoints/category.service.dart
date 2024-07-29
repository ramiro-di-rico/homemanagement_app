import 'package:home_management_app/models/category.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';
import 'dart:convert';

class CategoryService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;

  CategoryService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<CategoryModel>> fetch() async {
    var data = await this.apiServiceFactory.fetchList('category/v3');
    var result = data.map((e) => CategoryModel.fromJson(e)).toList();
    return result;
  }

  Future<CategoryModel> add(CategoryModel category) async {
    return await this.apiServiceFactory.postWithReturn('category/v3', json.encode(category.toJson()));
  }

  Future update(CategoryModel category) async {
    await this.apiServiceFactory.apiPut('category/v3', category.toJson());
  }

  Future delete(CategoryModel category) async {
    await this.apiServiceFactory.apiDelete('category/v3/', category.id.toString());
  }
}
