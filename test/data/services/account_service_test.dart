import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/services/account.service.dart';
import 'package:home_management_app/data/services/api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/domain/models/account.dart';

/// Stands in for the HTTP layer: records what was sent, and answers with [response].
class _Api implements ApiServiceFactory {
  dynamic response;
  Object? failWith;
  String? api;
  String? body;

  @override
  Future<dynamic> postWithReturn(String api, dynamic body) async {
    this.api = api;
    this.body = body as String;
    if (failWith != null) throw failWith!;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements AuthenticationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `POST account` answers 201 with the created account. The import depends on that
/// body (research R3), so what the client reads from it is checked here.
void main() {
  late _Api api;
  late AccountService service;

  setUp(() {
    api = _Api();
    service = AccountService(authenticationService: _Auth(), apiServiceFactory: api);
  });

  AccountModel draft({String name = 'Wallet', AccountType type = AccountType.BankAccount}) =>
      AccountModel(0, name, 0, true, type, 2, 0, false, false);

  test('add returns the account the server created, with its real id', () async {
    api.response = {
      'id': 101,
      'name': 'Wallet',
      'balance': 0,
      'accountType': 1,
      'currencyId': 2,
      'measurable': true,
      'archive': false,
      'isHidden': true,
      'userId': 7,
    };

    final created = await service.add(draft());

    expect(created.id, 101, reason: 'the import maps its local account to this id');
    expect(created.name, 'Wallet');
    expect(created.balance, 0);
    expect(created.accountType, AccountType.BankAccount);
    expect(created.currencyId, 2);
    expect(created.measurable, isTrue);
    expect(created.archive, isFalse);
    expect(created.isHidden, isTrue);
    expect(created.userId, 7);
  });

  test('add sends the account to the account endpoint as JSON', () async {
    api.response = {'id': 5, 'name': 'Savings', 'balance': 0, 'currencyId': 2};

    await service.add(draft(name: 'Savings', type: AccountType.Cash));

    expect(api.api, 'account');
    final sent = jsonDecode(api.body!) as Map<String, dynamic>;
    expect(sent['name'], 'Savings');
    expect(sent['accountType'], 0, reason: 'Cash is 0 and a bank account is 1');
    expect(sent['currencyId'], 2);
    expect(sent['measurable'], isTrue);
  });

  test('a body that leaves optional fields out still gives a usable account', () async {
    api.response = {'id': 9, 'name': 'Bare'};

    final created = await service.add(draft(name: 'Bare'));

    expect(created.id, 9);
    expect(created.balance, 0);
    expect(created.accountType, AccountType.Cash);
    expect(created.archive, isFalse);
    expect(created.isHidden, isFalse);
    expect(created.measurable, isFalse);
  });

  test('a balance sent as text is read as a number', () async {
    api.response = {'id': 3, 'name': 'Text', 'balance': '12.5'};

    expect((await service.add(draft())).balance, 12.5);
  });

  test('a failed request is not swallowed', () async {
    api.failWith = Exception('Failed to post to account');

    await expectLater(service.add(draft()), throwsException);
  });
}
