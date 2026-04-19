class MainAccountModel {
  int id, userId, childAccountCount;
  String name;
  bool isHidden;

  MainAccountModel(this.id, this.name, this.userId, this.childAccountCount, this.isHidden);

  factory MainAccountModel.fromJson(Map<String, dynamic> json) {
    return MainAccountModel(
      json['id'],
      json['name'],
      json['userId'],
      json['childAccountCount'],
      json['isHidden']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userId': userId,
    'childAccountCount': childAccountCount,
    'isHidden': isHidden
  };
}
