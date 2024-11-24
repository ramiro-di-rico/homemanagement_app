class CategoryHistoricalResponse{
  final int id;
  final String name;
  final List<CategoryHistoricalMonth> historical = [];

  CategoryHistoricalResponse(this.id, this.name);

  factory CategoryHistoricalResponse.fromJson(Map<String, dynamic> json){
    var historical = json['historical'] as List;
    return CategoryHistoricalResponse(
      json['id'],
      json['name']
    )..historical.addAll(historical.map((e) => CategoryHistoricalMonth.fromJson(e)));
  }
}

class CategoryHistoricalMonth{
  int month;
  double total;

  CategoryHistoricalMonth(this.month, this.total);

  factory CategoryHistoricalMonth.fromJson(Map<String, dynamic> json){
    var total = json['total'];
    return CategoryHistoricalMonth(
      json['month'],
      total is int ? total.toDouble() : total
    );
  }
}