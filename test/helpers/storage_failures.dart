import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:home_management_app/data/local/local_database.dart';

/// Makes every write fail with SQLITE_READONLY (code 8), the way a read-only or
/// full disk does. Reads keep working.
Future<void> makeStorageReadOnly(LocalDatabase db) =>
    db.customStatement('PRAGMA query_only = 1');

/// Makes every read throw while [error] is set, the way a failing disk does. Writes
/// and the opening of the database are left alone, so a test can set the data up
/// first and break reading afterwards.
class FailingReads extends QueryInterceptor {
  Object? error;

  @override
  Future<List<Map<String, Object?>>> runSelect(
      QueryExecutor executor, String statement, List<Object?> args) {
    final failure = error;
    if (failure != null) throw failure;
    return executor.runSelect(statement, args);
  }
}

/// SQLITE_IOERR (10): the disk failed.
SqliteException diskIoError() => SqliteException(extendedResultCode: 10, message: 'disk I/O error');

/// SQLITE_ERROR (1): something is wrong with the statement. That is a bug, not a
/// storage failure.
SqliteException sqlLogicError() => SqliteException(extendedResultCode: 1, message: 'SQL logic error');

/// An in-memory database whose reads fail while `failing.error` is set.
LocalDatabase openWithFailingReads(FailingReads failing) =>
    LocalDatabase(NativeDatabase.memory().interceptWith(failing));
