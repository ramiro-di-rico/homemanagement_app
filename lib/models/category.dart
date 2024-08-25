class CategoryModel{
  final int id, userId;
  String name, icon;
  final bool measurable, isActive;

  CategoryModel(this.id, this.userId, this.name, this.icon, this.measurable, this.isActive);

  factory CategoryModel.fromJson(Map<String, dynamic> json){
    return CategoryModel(
      json['id'],
      json['userId'],
      json['name'],
      json['icon'],
      json['measurable'],
      json['isActive']
    );
  }

  factory CategoryModel.empty(){
    return CategoryModel(0, 0, 'Category Model', '', false, false);
  }

  factory CategoryModel.create(String name){
    return CategoryModel(0, 0, name, 'empty', false, false);
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'measurable': measurable,
      'isActive': isActive
    };
  }
}

class UpdateCategoryModel{
  final int categoryId;
  final String name, icon;
  final bool measurable, isActive;

  UpdateCategoryModel(this.categoryId, this.name, this.icon, this.measurable, this.isActive);

  factory UpdateCategoryModel.fromCategoryModel(CategoryModel category){
    return UpdateCategoryModel(category.id, category.name, category.icon, category.measurable, category.isActive);
  }

  toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'measurable': measurable,
      'isActive': isActive
    };
  }
}