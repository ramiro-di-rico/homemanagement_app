class CategoryModel{
  final int id, userId;
  String name, icon, color;
  final bool measurable, isActive;

  CategoryModel(this.id, this.userId, this.name, this.icon, this.measurable, this.isActive, this.color);

  factory CategoryModel.fromJson(Map<String, dynamic> json){
    var color = json['color'] ?? '#ffffff';
    return CategoryModel(
      json['id'],
      json['userId'],
      json['name'],
      json['icon'],
      json['measurable'],
      json['isActive'],
      color
    );
  }

  factory CategoryModel.empty(){
    return CategoryModel(0, 0, 'Category Model', '', false, false, '#ffffff');
  }

  factory CategoryModel.create(String name){
    return CategoryModel(0, 0, name, 'empty', false, false, '#ffffff');
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'measurable': measurable,
      'isActive': isActive,
      'color': color
    };
  }
}

class UpdateCategoryModel{
  final int categoryId;
  final String name, icon, color;
  final bool measurable, isActive;

  UpdateCategoryModel(this.categoryId, this.name, this.icon, this.measurable, this.isActive, this.color);

  factory UpdateCategoryModel.fromCategoryModel(CategoryModel category){
    return UpdateCategoryModel(category.id, category.name, category.icon, category.measurable, category.isActive, category.color);
  }

  toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'measurable': measurable,
      'isActive': isActive,
      'color': color
    };
  }
}