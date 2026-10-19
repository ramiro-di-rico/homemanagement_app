import 'dart:io';

import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
import 'package:sqlite3/common.dart' show SqliteException;

/// Runs a write and turns a storage failure into [LocalWriteFailedException].
///
/// The app opens the database in a background isolate, where a failure arrives
/// wrapped in a [DriftRemoteException], so the cause is unwrapped first. Anything
/// else (validation errors, the typed "in use" exceptions, bugs) passes through.
Future<T> guardWrite<T>(Future<T> Function() write) async {
  try {
    return await write();
  } catch (error, stackTrace) {
    final cause = error is DriftRemoteException ? error.remoteCause : error;
    if (cause is SqliteException || cause is FileSystemException) {
      Error.throwWithStackTrace(LocalWriteFailedException(cause), stackTrace);
    }
    rethrow;
  }
}
