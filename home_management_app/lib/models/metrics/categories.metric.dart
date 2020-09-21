import 'package:home_management_app/models/category.dart';

class CategoriesMetric{
  List<CategoryMetric> categories;
  int highestValue;

  CategoriesMetric({this.categories, this.highestValue});

  factory CategoriesMetric.fromJson(Map<String, dynamic> json){
    List data = json['categories'];
    var categories = data.map((e) => CategoryMetric.fromJson(e)).toList();
    return CategoriesMetric(categories: categories, highestValue: json['highestValue']);
  }
}

class CategoryMetric{
  int price;
  CategoryModel category;
  CategoryMetric(this.price, this.category);

  factory CategoryMetric.fromJson(Map<String, dynamic> json){
    return CategoryMetric(
      json['price'],
      CategoryModel.fromJson(json['category'])
    );
  }
}