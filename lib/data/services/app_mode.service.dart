import 'package:flutter/foundation.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the local database. With [mustExist], a missing file is an error and
/// nothing is created.
typedef LocalDatabaseOpener = Future<LocalDatabase> Function(String fileName,
    {required bool mustExist});

typedef PreferencesLoader = Future<SharedPreferences> Function();

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
  final PreferencesLoader _loadPreferences;
  SharedPreferences? _preferences;
  Future<void>? _entering;

  bool _isLocal = false;
  LocalDatabase? _database;
  LocalDataUnavailableException? _startupError;
  ImportStatus _importStatus = ImportStatus.notStarted;

  AppModeService(
    this._platform, {
    SharedPreferences? preferences,
    LocalDatabaseOpener? openDatabase,
    PreferencesLoader? loadPreferences,
  })  : _preferences = preferences,
        _loadPreferences = loadPreferences ?? SharedPreferences.getInstance,
        _openDatabase = openDatabase ??
            ((fileName, {required mustExist}) =>
                openLocalDatabase(fileName: fileName, mustExist: mustExist));

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
  /// Nothing here may throw: it runs before the first frame, so a failure would
  /// mean no window at all, online users included. A failure to open the local
  /// data is kept in [startupError] and the mode stays local: the app must not
  /// fall back to online on its own, nor touch the file.
  Future<void> init() async {
    _startupError = null;
    try {
      _preferences ??= await _loadPreferences();
    } catch (_) {
      // Without preferences the app starts online, which needs none.
    }
    final wantsLocal =
        _preferences?.getString(preferenceKey) == localValue && isLocalAvailable;
    if (!wantsLocal) {
      _isLocal = false;
      notifyListeners();
      return;
    }
    _isLocal = true;
    try {
      // The user was already in local mode, so the data must be there.
      await _open(mustExist: true);
    } on LocalDataUnavailableException catch (e) {
      _startupError = e;
    }
    notifyListeners();
  }

  /// Opens or creates the local database and switches to local mode.
  ///
  /// Also the way to start over with empty data after a
  /// [LocalDataUnavailableReason.fileMissing], which only an explicit user action
  /// may do.
  ///
  /// Throws [LocalDataUnavailableException] (e.g. keyring unavailable). In that
  /// case the mode is left unchanged. Calls made while one is running share it,
  /// so a double click can't open the database twice.
  Future<void> enterLocalMode() =>
      _entering ??= _enterLocalMode().whenComplete(() => _entering = null);

  Future<void> _enterLocalMode() async {
    if (!isLocalAvailable) {
      throw StateError('Local mode is only available on desktop');
    }
    if (!_isLocal || _database == null) {
      await _open(mustExist: false);
    }
    _preferences ??= await _loadPreferences();
    await _preferences!.setString(preferenceKey, localValue);
    _isLocal = true;
    _startupError = null;
    notifyListeners();
  }

  /// Goes back to online mode and keeps the local data: the file is closed, never
  /// renamed or deleted, and entering local mode again reopens it.
  ///
  /// Also the way out of a [startupError], where the data can't be opened but the
  /// user still needs the app. Not allowed while an import is pending.
  Future<void> leaveLocalMode() async {
    if (isImportPending) {
      throw StateError('Finish the import before leaving local mode');
    }
    await _database?.close();
    _database = null;
    _preferences ??= await _loadPreferences();
    await _preferences!.setString(preferenceKey, onlineValue);
    _isLocal = false;
    _startupError = null;
    _importStatus = ImportStatus.notStarted;
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

  Future<void> _open({required bool mustExist}) async {
    await _database?.close();
    _database = null;
    LocalDatabase? opened;
    try {
      opened = await _openDatabase(activeFileName, mustExist: mustExist);
      final row = await opened.select(opened.importStates).getSingle();
      _importStatus = row.status;
      _database = opened;
    } on LocalDataUnavailableException {
      rethrow;
    } catch (e) {
      // Anything unexpected is reported like the known failures, so the caller can
      // show the "can't be opened" screen instead of crashing.
      await opened?.close();
      throw LocalDataUnavailableException(LocalDataUnavailableReason.unreadable,
          cause: e);
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
