class PreferenceModel {
  String name, value;

  PreferenceModel(this.name, this.value);

  factory PreferenceModel.fromJson(dynamic json) {
    return PreferenceModel(json['key'], json['value']);
  }

  Map toJson() => {
        'key': this.name,
        'value': this.value,
      };
}
