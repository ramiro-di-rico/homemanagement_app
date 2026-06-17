class TagModel {
  final int id;
  String name;

  TagModel(this.id, this.name);

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(json['id'], json['name'] ?? '');
  }

  factory TagModel.create(String name) {
    return TagModel(0, name);
  }

  factory TagModel.empty() {
    return TagModel(0, '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CreateTagRequest {
  String name;

  CreateTagRequest(this.name);

  Map<String, dynamic> toJson() => {'name': name};
}

class UpdateTagRequest {
  String name;

  UpdateTagRequest(this.name);

  Map<String, dynamic> toJson() => {'name': name};
}

class SyncTagsRequest {
  List<String> names;

  SyncTagsRequest(this.names);

  Map<String, dynamic> toJson() => {'names': names};
}
