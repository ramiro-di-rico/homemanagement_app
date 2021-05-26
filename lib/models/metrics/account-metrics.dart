class AccountSeries{

  int accountId;
  List<MonthSerie> monthSeries = [];

  AccountSeries(this.accountId);

  factory AccountSeries.fromJson(Map<String, dynamic> json){
    var account = AccountSeries(
      json['accountId']
    );
    var list = json['monthSeries'];
    var series = list.map((e) => MonthSerie.fromJson(e)).toList();

    var index = 0;
    for (var item in series) {
      item.index = index;
      account.monthSeries.add(item);
      index++;
    }
    return account;
  }
}

class MonthSerie{
  int month;
  String average;
  int index;

  MonthSerie(this.month, this.average, {this.index});

  factory MonthSerie.fromJson(Map<String, dynamic> json){
    return MonthSerie(
      json['month'], 
      json['average']);
  }
}