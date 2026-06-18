class Breakdown {
  String name;
  double value;

  Breakdown(this.name, this.value);

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(json['name'], double.parse(json['value'].toString()));
  }
}
