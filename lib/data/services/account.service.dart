import 'package:home_management_app/domain/models/account.dart';
import 'api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'dart:convert';
import 'package:home_management_app/data/services/sources/account_data_source.dart';

class AccountService implements AccountDataSource {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  final endpoint = 'account';

  AccountService(
      {required this.authenticationService, required this.apiServiceFactory});

  @override
  Future<List<AccountModel>> fetchAccounts() async {
    var list = await this.apiServiceFactory.fetchList(endpoint);
    var result = list.map((e) => AccountModel.fromJson(e)).toList();
    return result;
  }

  @override
  Future<AccountModel> add(AccountModel accountModel) async {
    var body = jsonEncode(accountModel);
    var result = await this.apiServiceFactory.postWithReturn(endpoint, body);
    return AccountModel.fromJson(result);
  }

  @override
  Future update(AccountModel account) async {
    var msg = jsonEncode(account);
    await apiServiceFactory.apiPut('$endpoint/${account.id}', msg);
  }

  @override
  Future delete(AccountModel accountModel) async {
    await this
        .apiServiceFactory
        .apiDelete(endpoint, accountModel.id.toString());
  }
}
