import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

import 'local_database.dart';

enum LocalDataUnavailableReason {
  /// The OS keyring is locked or missing.
  keyringUnavailable,

  /// The database file exists but its key is gone. A new key would not open it.
  keyMissing,

  /// The file opened without encryption. The app never runs unencrypted.
  notEncrypted,

  /// The file exists but can't be read with the stored key.
  unreadable,

  /// The app was in local mode, but its database file is gone (moved, deleted,
  /// or the application folder changed). A new empty one is never created silently.
  fileMissing,
}

class LocalDataUnavailableException implements Exception {
  final LocalDataUnavailableReason reason;
  final Object? cause;

  LocalDataUnavailableException(this.reason, {this.cause});

  @override
  String toString() =>
      'LocalDataUnavailableException(${reason.name}${cause == null ? '' : ': $cause'})';
}

const String localDatabaseKeyName = 'local_db_key_v1';

/// Opt-in, for macOS builds that are not signed with a development team
/// (`--dart-define=MACOS_LEGACY_KEYCHAIN=true`). The default, the data protection
/// keychain, needs the `keychain-access-groups` entitlement to be backed by a team
/// prefix, and an ad-hoc signed build gets error -34018 instead, which is reported
/// as `keyringUnavailable`.
///
/// **Do not mix the two on one machine.** The key is stored in one keychain or the
/// other. A file created by a build using one cannot be opened by a build using the
/// other: it is reported as `keyMissing` and the data is left alone. Use it only
/// for local development, never for a release.
const bool _macLegacyKeychain = bool.fromEnvironment('MACOS_LEGACY_KEYCHAIN');

/// How the key is stored on macOS. Other platforms ignore it.
MacOsOptions macOsKeychainOptions({bool legacyKeychain = _macLegacyKeychain}) =>
    MacOsOptions(usesDataProtectionKeychain: !legacyKeychain);

/// What a key may contain: the base64url alphabet the app generates. Anything else
/// means the stored value is damaged, and it must not reach the SQL (a quote would
/// break the statement, or silently change the passphrase).
final RegExp _keyPattern = RegExp(r'^[A-Za-z0-9_\-=]+$');

const String _keyRejected = 'PRAGMA key was not accepted by the SQLite library';

/// Sets the passphrase. It runs in the database's background isolate, before drift
/// creates or seeds anything, so nothing is written unless it succeeds.
///
/// sqlite3mc answers a single row, `ok`. Plain SQLite doesn't know the pragma and
/// answers nothing, which would otherwise go unnoticed until a plaintext file had
/// been written. `PRAGMA cipher` can't tell them apart: it reports a cipher either
/// way.
void applyKey(CommonDatabase db, String key) {
  final result = db.select("PRAGMA key = '$key'");
  if (result.length != 1 || result.first.values.first != 'ok') {
    throw StateError(_keyRejected);
  }
}

/// Opens the encrypted local database, creating it and its key on first use.
///
/// The key lives in the OS keyring and is passed to sqlite3mc as a passphrase,
/// the form the T005 spike verified. A failure never deletes or overwrites the
/// file, and never replaces the key of an existing file.
///
/// With [mustExist], a missing file is [LocalDataUnavailableReason.fileMissing]
/// and nothing is created, not even a key. Use it when the user was already in
/// local mode, so there must be data. Leave it off for the first entry.
///
/// [secureStorage] and [supportDirectory] are only meant to be replaced in tests.
Future<LocalDatabase> openLocalDatabase({
  required String fileName,
  bool mustExist = false,
  FlutterSecureStorage? secureStorage,
  Future<Directory> Function()? supportDirectory,
  // Only meant to be replaced in tests. It must be a top-level function: it runs in
  // the database's isolate.
  void Function(CommonDatabase, String) keySetup = applyKey,
}) async {
  final storage =
      secureStorage ?? FlutterSecureStorage(mOptions: macOsKeychainOptions());
  final directory = await (supportDirectory ?? getApplicationSupportDirectory)();
  final name = fileName.endsWith('.sqlite')
      ? fileName.substring(0, fileName.length - '.sqlite'.length)
      : fileName;
  final file = File('${directory.path}${Platform.pathSeparator}$name.sqlite');

  final fileExists = await file.exists();
  if (mustExist && !fileExists) {
    throw LocalDataUnavailableException(LocalDataUnavailableReason.fileMissing);
  }

  final key = await _readOrCreateKey(storage, fileExists: fileExists);
  if (!_keyPattern.hasMatch(key)) {
    // Checked before the file is touched. The key itself is never put in the error.
    throw LocalDataUnavailableException(LocalDataUnavailableReason.unreadable,
        cause: 'the stored key has unexpected characters');
  }

  final database = LocalDatabase(driftDatabase(
    name: name,
    native: DriftNativeOptions(
      databaseDirectory: () async => directory,
      // Runs in a background isolate, so it captures only the key String and a
      // top-level function.
      setup: (db) => keySetup(db, key),
    ),
  ));

  try {
    final cipher = await database.customSelect('PRAGMA cipher').get();
    if (cipher.isEmpty) {
      await database.close();
      throw LocalDataUnavailableException(
          LocalDataUnavailableReason.notEncrypted);
    }
    // Forces the schema to load, which fails with a wrong key.
    await database.customSelect('SELECT count(*) FROM sqlite_master').get();
  } on LocalDataUnavailableException {
    rethrow;
  } catch (e) {
    await database.close();
    // The setup failure comes back wrapped, from another isolate, so it is found
    // by its message.
    if (e.toString().contains(_keyRejected)) {
      throw LocalDataUnavailableException(
          LocalDataUnavailableReason.notEncrypted);
    }
    throw LocalDataUnavailableException(LocalDataUnavailableReason.unreadable,
        cause: e);
  }
  return database;
}

Future<String> _readOrCreateKey(FlutterSecureStorage storage,
    {required bool fileExists}) async {
  try {
    final existing = await storage.read(key: localDatabaseKeyName);
    if (existing != null && existing.isNotEmpty) return existing;
    if (fileExists) {
      throw LocalDataUnavailableException(LocalDataUnavailableReason.keyMissing);
    }
    final random = Random.secure();
    final key =
        base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256)));
    await storage.write(key: localDatabaseKeyName, value: key);
    // Use what the keyring now holds, not what this call generated: if two
    // calls raced, the file must be created with the key that stays stored.
    final stored = await storage.read(key: localDatabaseKeyName);
    if (stored == null || stored.isEmpty) {
      throw LocalDataUnavailableException(
          LocalDataUnavailableReason.keyringUnavailable);
    }
    return stored;
  } on PlatformException catch (e) {
    throw LocalDataUnavailableException(
        LocalDataUnavailableReason.keyringUnavailable,
        cause: e);
  }
}
