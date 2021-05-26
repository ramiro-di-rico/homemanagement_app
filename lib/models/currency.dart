class CurrencyModel {
  final int id;
  final String name;
  final double value;

  CurrencyModel(this.id, this.name, this.value);

  factory CurrencyModel.fromJson(Map<String, dynamic> json){
    return CurrencyModel(
      json['id'], 
      json['name'], 
      double.parse(json['value'].toString()), 
    );
  }
}