import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart' show CommonDatabase, ResultSet;
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
// A transitive dependency (through path_provider), only used to fake the temp folder.
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakeKeyring implements FlutterSecureStorage {
  final Map<String, String> data = {};
  bool locked = false;
  int writes = 0;

  /// Simulates another call that stores its own key right after this one.
  String? racingKey;

  @override
  Future<String?> read({required String key, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions, dynamic wOptions}) async {
    if (locked) throw PlatformException(code: 'KeyringLocked');
    return data[key];
  }

  @override
  Future<void> write({required String key, required String? value, dynamic iOptions, dynamic aOptions, dynamic lOptions, dynamic webOptions, dynamic mOptions, dynamic wOptions}) async {
    if (locked) throw PlatformException(code: 'KeyringLocked');
    writes++;
    data[key] = value!;
    if (racingKey != null) data[key] = racingKey!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A SQLite that doesn't know `PRAGMA key`: it answers with no rows, like the
/// stock library does.
class _PlainSqlite implements CommonDatabase {
  final List<List<Object?>> rows;
  _PlainSqlite([this.rows = const []]);

  @override
  ResultSet select(String sql, [List<Object?> parameters = const []]) =>
      ResultSet(['key'], [null], rows);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Stands in for a build without sqlite3mc. Top-level, because it runs in the
/// database's isolate.
void plainSqliteKeySetup(CommonDatabase db, String key) =>
    applyKey(_PlainSqlite(), key);

class _FakePaths extends PathProviderPlatform {
  final String temporary;
  _FakePaths(this.temporary);

  @override
  Future<String?> getTemporaryPath() async => temporary;
}

void main() {
  late Directory dir;
  late _FakeKeyring keyring;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('opener');
    PathProviderPlatform.instance = _FakePaths(dir.path);
    keyring = _FakeKeyring();
    file = File('${dir.path}/local.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<LocalDatabase> open({bool mustExist = false}) => openLocalDatabase(
      fileName: 'local.sqlite',
      mustExist: mustExist,
      secureStorage: keyring,
      supportDirectory: () async => dir);

  Matcher unavailable(LocalDataUnavailableReason reason) => throwsA(
      isA<LocalDataUnavailableException>().having((e) => e.reason, 'reason', reason));

  test('the first run creates a key and an encrypted, seeded file', () async {
    final db = await open();

    expect(keyring.data[localDatabaseKeyName], isNotEmpty);
    expect((await db.select(db.categories).get()), hasLength(17));
    await db.close();
    final header = String.fromCharCodes(file.openSync().readSync(15));
    expect(header, isNot('SQLite format 3'));
  });

  test('the next start reuses the key and finds the data', () async {
    await (await open()).close();
    final key = keyring.data[localDatabaseKeyName];

    final db = await open();

    expect(keyring.data[localDatabaseKeyName], key);
    expect(keyring.writes, 1, reason: 'no new key');
    expect((await db.select(db.categories).get()), hasLength(17));
    await db.close();
  });

  test('the file is created with the key that stays stored when two starts race', () async {
    keyring.racingKey = 'theOtherCallsKey_theOtherCallsKey_theOtherCa=';

    await (await open()).close();
    keyring.racingKey = null;

    expect(keyring.data[localDatabaseKeyName], 'theOtherCallsKey_theOtherCallsKey_theOtherCa=');
    final db = await open();
    expect((await db.select(db.categories).get()), hasLength(17),
        reason: 'the stored key opens the file, so the data is not locked out');
    await db.close();
  });

  test('a lost key for an existing file is reported, and no key or file change is made', () async {
    await (await open()).close();
    final size = file.lengthSync();
    keyring.data.clear();
    final writesBefore = keyring.writes;

    await expectLater(open(), unavailable(LocalDataUnavailableReason.keyMissing));

    expect(keyring.data, isEmpty, reason: 'a new key must never be created for an existing file');
    expect(keyring.writes, writesBefore);
    expect(file.lengthSync(), size);
  });

  test('a wrong key is reported as unreadable and the file is untouched', () async {
    await (await open()).close();
    final size = file.lengthSync();
    final modified = file.lastModifiedSync();
    keyring.data[localDatabaseKeyName] = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';

    await expectLater(open(), unavailable(LocalDataUnavailableReason.unreadable));

    expect(file.lengthSync(), size);
    expect(file.lastModifiedSync(), modified);
  });

  test('a locked keyring is reported and creates no file', () async {
    keyring.locked = true;

    await expectLater(open(), unavailable(LocalDataUnavailableReason.keyringUnavailable));

    expect(file.existsSync(), isFalse);
  });

  group('when the user was already in local mode', () {
    test('a missing file is reported before anything is created', () async {
      keyring.data[localDatabaseKeyName] = 'someKeyFromAnEarlierRun';
      final writesBefore = keyring.writes;

      await expectLater(open(mustExist: true), unavailable(LocalDataUnavailableReason.fileMissing));

      expect(file.existsSync(), isFalse, reason: 'no empty database may replace the lost one');
      expect(keyring.writes, writesBefore);
    });

    test('a missing file does not even touch the keyring', () async {
      keyring.locked = true;

      await expectLater(open(mustExist: true), unavailable(LocalDataUnavailableReason.fileMissing));
    });

    test('an existing file opens as usual', () async {
      await (await open()).close();

      final db = await open(mustExist: true);

      expect((await db.select(db.categories).get()), hasLength(17));
      await db.close();
    });
  });

  group('the key is checked, and nothing is written when it is refused (RF-13)', () {
    for (final (label, key) in [
      ('a quote', "ab'cd"),
      ('a space', 'ab cd'),
      ('a semicolon', 'abc;DROP TABLE x'),
      ('a newline', 'ab\ncd'),
    ]) {
      test('a stored key with $label is rejected before a file is created', () async {
        keyring.data[localDatabaseKeyName] = key;

        await expectLater(open(), unavailable(LocalDataUnavailableReason.unreadable));

        expect(file.existsSync(), isFalse);
        expect(keyring.data[localDatabaseKeyName], key, reason: 'the keyring value is left alone');
      });
    }

    test('a damaged key never replaces the data of an existing file', () async {
      final database = await open();
      await database.close();
      final before = file.readAsBytesSync();
      keyring.data[localDatabaseKeyName] = "it's damaged";

      await expectLater(open(), unavailable(LocalDataUnavailableReason.unreadable));

      expect(file.readAsBytesSync(), before);
    });

    test('the damaged key does not appear in the error', () async {
      keyring.data[localDatabaseKeyName] = "secret'value";

      try {
        await open();
        fail('expected an error');
      } on LocalDataUnavailableException catch (e) {
        expect(e.toString(), isNot(contains('secret')));
      }
    });

    test('every key the app generates passes the check', () async {
      // base64url, with the padding characters that can end it.
      for (var i = 0; i < 20; i++) {
        keyring.data.clear();
        final database = await open();
        await database.close();
        file.deleteSync();
      }
    });

    test('applyKey accepts sqlite3mc and refuses a SQLite that ignores the pragma', () {
      expect(() => applyKey(_PlainSqlite([['ok']]), 'abc'), returnsNormally);
      expect(() => applyKey(_PlainSqlite(), 'abc'), throwsStateError);
      expect(() => applyKey(_PlainSqlite([['no']]), 'abc'), throwsStateError);
      expect(() => applyKey(_PlainSqlite([['ok'], ['ok']]), 'abc'), throwsStateError);
    });

    test('a library that refuses the key is reported as not encrypted, with no data written',
        () async {
      await expectLater(
          openLocalDatabase(
              fileName: 'local.sqlite',
              secureStorage: keyring,
              supportDirectory: () async => dir,
              keySetup: plainSqliteKeySetup),
          unavailable(LocalDataUnavailableReason.notEncrypted));

      // Drift would have created and seeded the schema on its first query, in plain text.
      expect(file.existsSync() ? file.lengthSync() : 0, 0);
    });
  });
}
