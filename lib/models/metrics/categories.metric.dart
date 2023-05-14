import 'package:home_management_app/models/category.dart';

class CategoriesMetric {
  List<CategoryMetric>? categories;
  double? highestValue;

  CategoriesMetric({this.categories, this.highestValue});

  factory CategoriesMetric.fromJson(Map<String, dynamic> json) {
    List data = json['categories'];
    var categories = data.map((e) => CategoryMetric.fromJson(e)).toList();
    return CategoriesMetric(
        categories: categories,
        highestValue: double.parse(json['highestValue'].toString()));
  }
}

class CategoryMetric {
  double price;
  CategoryModel category;
  CategoryMetric(this.price, this.category);

  factory CategoryMetric.fromJson(Map<String, dynamic> json) {
    return CategoryMetric(double.parse(json['price'].toString()),
        CategoryModel.fromJson(json['category']));
  }
}
