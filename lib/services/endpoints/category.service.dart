import 'package:home_management_app/models/category.dart';
import 'api.service.factory.dart';
import '../authentication.service.dart';

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
}
