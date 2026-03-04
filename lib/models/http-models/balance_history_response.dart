class BalanceHistoryResponse {
  final int id;
  final int accountId;
  final double balance;
  final DateTime date;

  BalanceHistoryResponse({
    required this.id,
    required this.accountId,
    required this.balance,
    required this.date,
  });

  factory BalanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    var balance = json['balance'];
    return BalanceHistoryResponse(
      id: json['id'],
      accountId: json['accountId'],
      balance: balance is int ? balance.toDouble() : balance.toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}
