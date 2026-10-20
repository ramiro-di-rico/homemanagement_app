import 'package:home_management_app/data/local/local_database.dart';

/// Makes every write fail with SQLITE_READONLY (code 8), the way a read-only or
/// full disk does. Reads keep working.
Future<void> makeStorageReadOnly(LocalDatabase db) =>
    db.customStatement('PRAGMA query_only = 1');
