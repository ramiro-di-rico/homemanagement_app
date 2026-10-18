import 'package:flutter/foundation.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LocalDatabaseOpener = Future<LocalDatabase> Function(String fileName);

/// Whether the app works against the server (online) or the encrypted local
/// database (standalone desktop mode). Repositories are built once with
/// mode-aware delegates, so flipping the mode needs no re-registration.
class AppModeService extends ChangeNotifier {
  static const String preferenceKey = 'appMode';
  static const String onlineValue = 'online';
  static const String localValue = 'local';

  /// The active local file. Archiving it (T067) is what makes the next local
  /// session start fresh.
  static const String activeFileName = 'homemanagement_local.sqlite';

  final PlatformContext _platform;
  final LocalDatabaseOpener _openDatabase;
  SharedPreferences? _preferences;

  bool _isLocal = false;
  LocalDatabase? _database;
  LocalDataUnavailableException? _startupError;
  ImportStatus _importStatus = ImportStatus.notStarted;

  AppModeService(
    this._platform, {
    SharedPreferences? preferences,
    LocalDatabaseOpener? openDatabase,
  })  : _preferences = preferences,
        _openDatabase =
            openDatabase ?? ((fileName) => openLocalDatabase(fileName: fileName));

  /// Desktop only. Not the web, which has no file system or keyring.
  bool get isLocalAvailable =>
      _platform.getPlatformType() == PlatformType.Desktop;

  bool get isLocal => _isLocal;

  /// Set while [isLocal] and the local data was opened.
  LocalDatabase? get database => _database;

  /// Why the local data couldn't be opened at startup. Never cleared by deleting data.
  LocalDataUnavailableException? get startupError => _startupError;

  /// True while an import is `inProgress` or `failed`. Local writes are locked meanwhile.
  bool get isImportPending =>
      _importStatus == ImportStatus.inProgress ||
      _importStatus == ImportStatus.failed;

  /// Runs at startup, and again on "Retry" after a [startupError].
  ///
  /// A failure to open the local data is kept in [startupError] and the mode
  /// stays local: the app must not fall back to online, nor touch the file.
  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
    _startupError = null;
    final wantsLocal =
        _preferences!.getString(preferenceKey) == localValue && isLocalAvailable;
    if (!wantsLocal) {
      _isLocal = false;
      notifyListeners();
      return;
    }
    _isLocal = true;
    try {
      await _open();
    } on LocalDataUnavailableException catch (e) {
      _startupError = e;
    }
    notifyListeners();
  }

  /// Opens or creates the local database and switches to local mode.
  ///
  /// Throws [LocalDataUnavailableException] (e.g. keyring unavailable). In that
  /// case the mode is left unchanged.
  Future<void> enterLocalMode() async {
    if (!isLocalAvailable) {
      throw StateError('Local mode is only available on desktop');
    }
    if (!_isLocal || _database == null) {
      await _open();
    }
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setString(preferenceKey, localValue);
    _isLocal = true;
    _startupError = null;
    notifyListeners();
  }

  /// Re-reads `import_states` after the import changes it.
  Future<void> refreshImportStatus() async {
    final db = _database;
    if (db == null) return;
    final row = await db.select(db.importStates).getSingle();
    if (row.status == _importStatus) return;
    _importStatus = row.status;
    notifyListeners();
  }

  /// Implemented with the import (US4, T067).
  Future<void> completeImport() async {
    throw UnimplementedError('completeImport is implemented in T067');
  }

  Future<void> _open() async {
    await _database?.close();
    _database = null;
    _database = await _openDatabase(activeFileName);
    final row = await _database!.select(_database!.importStates).getSingle();
    _importStatus = row.status;
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
