class AccountHistorical {
  String account;
  List<AccountEvolution> evolution = [];

  AccountHistorical(this.account);

  factory AccountHistorical.fromJson(Map<String, dynamic> json) {
    List data = json['evolution'];
    var evolution = data.map((e) => AccountEvolution.fromJson(e)).toList();
    var model = AccountHistorical(json['account'].toString());

    var index = 0;
    for (var item in evolution) {
      item.index = index;
      model.evolution.add(item);
      index++;
    }

    return model;
  }
}

class AccountEvolution {
  String month;
  double balance;
  int? index;

  AccountEvolution(this.month, this.balance, {this.index});

  factory AccountEvolution.fromJson(Map<String, dynamic> json) {
    return AccountEvolution(
        json['month'].toString(), double.parse(json['balance'].toString()));
  }
}
