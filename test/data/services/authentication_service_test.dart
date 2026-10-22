import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/user.repository.dart';
import 'package:home_management_app/data/services/account.service.dart';
import 'package:home_management_app/data/services/api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/cryptography.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/domain/models/user.dart';
import 'package:home_management_app/ui/features/authentication/view_models/user-view-model.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

/// A failed sign-in used to set `user` to null. The next request then crashed on
/// `user!` with "Null check operator used on a null value" instead of failing like
/// any other request.
void main() {
  late AuthenticationService auth;
  var signInStatus = 200;
  late List<String> requests;

  String signInBody(String token) => jsonEncode({
        'email': 'a@b.com',
        'username': 'a@b.com',
        'token': token,
        'refreshToken': 'r',
        'expirationDate':
            DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
        'twoFactorRequired': false,
      });

  final login = UserViewModel()
    ..email = 'a@b.com'
    ..password = 'secret-123';

  Future<T> withServer<T>(Future<T> Function() body) => http.runWithClient(body, () {
        return MockClient((request) async {
          requests.add('${request.method} ${request.url.path} ${request.headers['Authorization'] ?? ''}');
          if (request.url.path.contains('Authentication/SignIn')) {
            return signInStatus == 200
                ? http.Response(signInBody('token-1'), 200)
                : http.Response('', signInStatus);
          }
          return http.Response('[]', 401);
        });
      });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    signInStatus = 200;
    requests = [];
    auth = AuthenticationService(CryptographyService(), UserRepository(),
        FakePlatform(PlatformType.Desktop), NotifierService(), null);
  });

  test('a failed sign-in keeps the user who is signed in', () async {
    await withServer(() async {
      expect(await auth.authenticate(login), isTrue);
      expect(auth.getUserToken(), 'token-1');

      signInStatus = 401;
      expect(await auth.authenticate(login), isFalse);
    });

    expect(auth.user, isNotNull, reason: 'the failed attempt must not sign them out');
    expect(auth.getUserToken(), 'token-1');
  });

  test('a failed sign-in with nobody signed in leaves nobody signed in', () async {
    signInStatus = 401;

    await withServer(() async => expect(await auth.authenticate(login), isFalse));

    expect(auth.user, isNull);
  });

  test('a request whose token expired and could not be renewed fails like any request, '
      'not with a null check', () async {
    final expired = UserModel('a@b.com', 'a@b.com', 'secret', 'old-token', 'r',
        DateTime.now().toUtc().subtract(const Duration(hours: 1)), false);
    auth.user = expired;
    signInStatus = 401;
    final accounts = AccountService(
        authenticationService: auth, apiServiceFactory: ApiServiceFactory(authenticationService: auth));

    await withServer(() async {
      await expectLater(accounts.fetchAccounts(),
          throwsA(isA<Exception>().having((e) => e is TypeError, 'is a null-check error', isFalse)));
    });

    expect(requests.first, contains('Authentication/SignIn'), reason: 'it tried to renew first');
    expect(auth.user, isNotNull);
  });

  test('a successful sign-in replaces the user', () async {
    await withServer(() async {
      await auth.authenticate(login);
      final first = auth.user;

      expect(await auth.authenticate(login), isTrue);
      expect(identical(auth.user, first), isFalse, reason: 'the new session is the one kept');
    });
  });
}
