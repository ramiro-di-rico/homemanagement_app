import 'package:home_management_app/models/transaction.dart';

class TransactionPageModel {
  int accountId, currentPage, pageCount, totalPages, op;
  String property, filterValue;
  List<TransactionModel> items = [];

  TransactionPageModel();

  factory TransactionPageModel.newPage(
      int accountId, int currentPage, int pageCount) {
    var model = TransactionPageModel();
    model.accountId = accountId;
    model.currentPage = currentPage;
    model.pageCount = pageCount;
    return model;
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId.toString(),
        'currentPage': currentPage.toString(),
        'pageCount': pageCount.toString()
      };

  factory TransactionPageModel.fromJson(dynamic json) {
    var model = TransactionPageModel();
    model.items = json['items']
        .map<TransactionModel>((e) => TransactionModel.fromJson(e))
        .toList();
    return model;
  }
}
