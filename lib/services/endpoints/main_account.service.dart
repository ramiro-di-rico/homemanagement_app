import 'dart:convert';
import 'package:home_management_app/models/account.dart';
import 'package:home_management_app/models/main_account.dart';
import 'api.service.factory.dart';
import '../security/authentication.service.dart';

class MainAccountService {
  AuthenticationService authenticationService;
  ApiServiceFactory apiServiceFactory;
  final endpoint = 'MainAccount';

  MainAccountService(
      {required this.authenticationService, required this.apiServiceFactory});

  Future<List<MainAccountModel>> fetchMainAccounts() async {
    var list = await this.apiServiceFactory.fetchList(endpoint);
    var result = list.map((e) => MainAccountModel.fromJson(e)).toList();
    return result;
  }

  Future add(MainAccountModel mainAccount) async {
    var body = jsonEncode(mainAccount);
    await this.apiServiceFactory.apiPost(endpoint, body);
  }

  Future update(MainAccountModel mainAccount) async {
    var msg = jsonEncode(mainAccount);
    await apiServiceFactory.apiPut('$endpoint/${mainAccount.id}', msg);
  }

  Future delete(MainAccountModel mainAccount) async {
    await this
        .apiServiceFactory
        .apiDelete(endpoint, mainAccount.id.toString());
  }

  Future<List<AccountModel>> fetchAccounts(int mainAccountId) async {
    var list = await this.apiServiceFactory.fetchList('$endpoint/$mainAccountId/accounts');
    var result = list.map((e) => AccountModel.fromJson(e)).toList();
    return result;
  }

  Future addAccount(int mainAccountId, int accountId) async {
    await this.apiServiceFactory.apiPost('$endpoint/$mainAccountId/accounts/$accountId', '');
  }

  Future removeAccount(int mainAccountId, int accountId) async {
    await this.apiServiceFactory.apiDelete('$endpoint/$mainAccountId/accounts', accountId.toString());
  }
}
