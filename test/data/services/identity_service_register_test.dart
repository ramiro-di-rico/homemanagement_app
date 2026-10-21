import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/services/identity.service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// `IdentityService` uses the top-level `http` functions, so the fake client is
/// installed for the zone with `runWithClient` instead of being injected.
void main() {
  Future<RegistrationResult> register(
    int status,
    String body,
    List<http.Request> sent,
  ) {
    return http.runWithClient(
      () => IdentityService(null).register('a@b.com', 'Secret-1', 'en'),
      () => MockClient((request) async {
        sent.add(request);
        return http.Response(body, status);
      }),
    );
  }

  test(
    '200 is a success, and the body carries email, password and language',
    () async {
      final sent = <http.Request>[];

      final result = await register(200, '', sent);

      expect(result, RegistrationResult.success);
      expect(sent, hasLength(1));
      expect(sent.single.url.path, '/identity/api/registration');
      expect(jsonDecode(sent.single.body), {
        'email': 'a@b.com',
        'password': 'Secret-1',
        'language': 'en',
      });
    },
  );

  for (final code in ['DuplicateEmail', 'DuplicateUserName']) {
    test('400 with $code means the email is taken', () async {
      final result = await register(
        400,
        jsonEncode([
          {'code': code, 'description': 'Email is already taken.'},
        ]),
        [],
      );

      expect(result, RegistrationResult.emailTaken);
    });
  }

  test('a 400 for another reason is a plain failure', () async {
    final result = await register(
      400,
      jsonEncode([
        {'code': 'PasswordTooShort', 'description': 'Too short.'},
      ]),
      [],
    );

    expect(result, RegistrationResult.failed);
  });

  test('a 400 with an empty or non-JSON body is a plain failure', () async {
    expect(await register(400, '', []), RegistrationResult.failed);
    expect(await register(400, 'Bad Request', []), RegistrationResult.failed);
  });

  for (final status in [500, 502, 503]) {
    test(
      '$status is a plain failure, even if the body names a duplicate',
      () async {
        final result = await register(status, 'DuplicateEmail', []);

        expect(result, RegistrationResult.failed);
      },
    );
  }
}
