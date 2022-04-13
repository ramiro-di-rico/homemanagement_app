class Metric {
  double percentage;
  double total;

  Metric(this.percentage, this.total);

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(double.parse(json['percentage'].toString()),
        double.parse(json['total'].toString()));
  }
}
