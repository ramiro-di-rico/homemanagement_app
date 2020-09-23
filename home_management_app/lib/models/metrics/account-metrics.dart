class AccountSeries{

  int accountId;
  List<MonthSerie> monthSeries = List<MonthSerie>();

  AccountSeries(this.accountId);

  factory AccountSeries.fromJson(Map<String, dynamic> json){
    var account = AccountSeries(
      json['accountId']
    );
    var list = json['monthSeries'];
    var series = list.map((e) => MonthSerie.fromJson(e)).toList();

    for (var item in series) {
      account.monthSeries.add(item);
    }
    return account;
  }
}

class MonthSerie{
  int month;
  String average;

  MonthSerie(this.month, this.average);

  factory MonthSerie.fromJson(Map<String, dynamic> json){
    return MonthSerie(
      json['month'], 
      json['average']);
  }
}