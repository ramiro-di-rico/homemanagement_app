import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

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
}) async {
  final storage = secureStorage ?? const FlutterSecureStorage();
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

  final database = LocalDatabase(driftDatabase(
    name: name,
    native: DriftNativeOptions(
      databaseDirectory: () async => directory,
      // Runs in a background isolate, so it captures only the key String.
      setup: (db) => db.execute("PRAGMA key = '$key';"),
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
