import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'dart:convert';
import 'package:home_management_app/data/services/sources/category_data_source.dart';

class CategoryService implements CategoryDataSource {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  NotifierService notifierService;

  final String categoryEndpoint = 'category/v1';

  CategoryService(
      {required this.authenticationService,
        required this.apiServiceFactory,
        required this.notifierService});

  @override
  Future<List<CategoryModel>> fetch() async {
    var data = await this.apiServiceFactory.fetchList(categoryEndpoint);
    var result = data.map((e) => CategoryModel.fromJson(e)).toList();
    return result;
  }

  @override
  Future<CategoryModel> add(CategoryModel category) async {
    var result = await this.apiServiceFactory.postWithReturn(categoryEndpoint, json.encode(category));
    notifierService.notify('Category ${category.name} added');
    return CategoryModel.fromJson(result);
  }

  @override
  Future update(CategoryModel category) async {
    var updateCategory = UpdateCategoryModel.fromCategoryModel(category);
    await this.apiServiceFactory.apiPut(categoryEndpoint, json.encode(updateCategory));
    notifierService.notify('Category ${category.name} updated');
  }

  @override
  Future delete(CategoryModel category) async {
    await this.apiServiceFactory.apiDelete('${categoryEndpoint}/', category.id.toString());
    notifierService.notify('Category ${category.name} deleted');
  }
}
