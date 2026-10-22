import 'dart:io';

import 'package:drift/drift.dart' show CouldNotRollBackException;
import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:home_management_app/data/services/sources/local_read_failed_exception.dart';
import 'package:home_management_app/data/services/sources/local_write_failed_exception.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import 'local_database.dart';

/// SQLite result codes that mean the storage failed, as opposed to the data being
/// rejected: busy or locked, out of memory, read-only, I/O error, corrupt, disk
/// full, can't open, not a database.
const _storageFailureCodes = {5, 6, 7, 8, 10, 11, 13, 14, 26};

/// Runs a write and turns a *storage* failure (a full disk, a read-only file, an
/// I/O error) into [LocalWriteFailedException].
///
/// The real error is unwrapped first (see [_rootCause]). Anything
/// else passes through unchanged: validation errors, the typed "in use" and "name
/// taken" exceptions, and constraint or SQL errors, which are bugs and must not be
/// shown to the user as "not saved".
Future<T> guardWrite<T>(Future<T> Function() write) async {
  try {
    return await write();
  } catch (error, stackTrace) {
    final cause = _rootCause(error);
    if (_isStorageFailure(cause)) {
      Error.throwWithStackTrace(LocalWriteFailedException(cause), stackTrace);
    }
    rethrow;
  }
}

/// The same for a read: a *storage* failure becomes [LocalReadFailedException], so
/// the repositories can say the data couldn't be read instead of letting a raw
/// database error reach the screen. Anything else passes through unchanged.
Future<T> guardRead<T>(Future<T> Function() read) async {
  try {
    return await read();
  } catch (error, stackTrace) {
    final cause = _rootCause(error);
    if (_isStorageFailure(cause)) {
      Error.throwWithStackTrace(LocalReadFailedException(cause), stackTrace);
    }
    rethrow;
  }
}

bool _isStorageFailure(Object cause) =>
    cause is FileSystemException ||
    (cause is SqliteException && _storageFailureCodes.contains(cause.resultCode));

/// Looks through the wrappers drift puts around the real error: a
/// [DriftRemoteException] from the background isolate, and a
/// [CouldNotRollBackException], which a full disk causes when SQLite already
/// rolled the transaction back itself.
Object _rootCause(Object error) {
  var cause = error;
  while (true) {
    if (cause is DriftRemoteException) {
      cause = cause.remoteCause;
    } else if (cause is CouldNotRollBackException) {
      cause = cause.cause;
    } else {
      return cause;
    }
  }
}

/// [guardWrite] around a transaction, so a check and the write that depends on it
/// can't be split by another call (a double click) and a failure leaves nothing behind.
Future<T> guardedTransaction<T>(LocalDatabase db, Future<T> Function() body) =>
    guardWrite(() => db.transaction(body));
