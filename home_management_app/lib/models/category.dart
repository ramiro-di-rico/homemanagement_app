class CategoryModel{
  final int id, userId;
  final String name, icon;
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
}