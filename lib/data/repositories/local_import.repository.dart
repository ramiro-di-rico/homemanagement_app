import 'package:flutter/foundation.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/models/import_mismatch.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/local_import.service.dart';

/// State of the move from the local database to the new account, for the import
/// screen. The work itself is [LocalImportService]. When it succeeds, this calls
/// [AppModeService.completeImport], which archives the local file and goes online.
class LocalImportRepository extends ChangeNotifier {
  final AppModeService _appMode;
  final AuthenticationService _authentication;
  final LocalImportService Function(LocalDatabase database) _createService;

  ImportStatus _status = ImportStatus.notStarted;
  ImportStep? _step;
  (int, int) _progress = (0, 0);
  List<ImportMismatch> _mismatches = const [];
  Object? _error;
  bool _running = false;

  LocalImportRepository({
    required AppModeService appMode,
    required AuthenticationService authentication,
    required LocalImportService Function(LocalDatabase database) createService,
  }) : _appMode = appMode,
       _authentication = authentication,
       _createService = createService {
    _status = appMode.importStatus;
    _appMode.addListener(_onModeChanged);
  }

  /// This repository lives as long as the app, but an import belongs to one local
  /// session. A new local session (after an archived import, or another start) must
  /// not inherit the previous status, error or mismatches. Online it keeps them,
  /// because the summary of a finished import is read after the app went online.
  void _onModeChanged() {
    if (_running || !_appMode.isLocal) return;
    final status = _appMode.importStatus;
    if (status == _status && status != ImportStatus.notStarted) return;
    _status = status;
    if (status == ImportStatus.notStarted) {
      _step = null;
      _progress = (0, 0);
      _mismatches = const [];
      _error = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _appMode.removeListener(_onModeChanged);
    super.dispose();
  }

  /// `notStarted`, `inProgress` (also while this is running), `failed` or `completed`.
  ImportStatus get status => _status;

  /// The step being worked on, and how far it is: (done, total).
  ImportStep? get step => _step;
  (int, int) get progress => _progress;

  /// Accounts whose online balance differs from the local one, once finished (FR-023).
  List<ImportMismatch> get mismatches => _mismatches;

  /// The last failure, e.g. [ImportCurrencyMissingException] or [ImportWrongUserException].
  Object? get error => _error;

  bool get isRunning => _running;

  /// Begins a first import. Does nothing while one is running.
  Future<void> start() => _run();

  /// Continues a failed or interrupted import. The service picks up from what
  /// is already stored, so this is the same call as [start].
  Future<void> resume() => _run();

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    _error = null;
    _status = ImportStatus.inProgress;
    _step = null;
    _progress = (0, 0);
    notifyListeners();

    var lockRefreshed = false;
    try {
      final database = _appMode.database;
      final email = _authentication.user?.email;
      if (database == null || email == null || email.isEmpty) {
        throw StateError(
          'The import needs the local data and a signed-in user',
        );
      }
      final result = await _createService(database).run(
        email: email,
        onProgress: (step, done, total) {
          if (!lockRefreshed) {
            // The service has stored `inProgress` by now: lock local writes.
            lockRefreshed = true;
            _appMode.refreshImportStatus();
          }
          _step = step;
          _progress = (done, total);
          notifyListeners();
        },
      );
      _mismatches = result.mismatches;
      _status = ImportStatus.completed;
      notifyListeners();
      await _appMode.completeImport();
    } catch (error) {
      _error = error;
      _status = ImportStatus.failed;
      // Keeps (or sets) the write lock, so the data can't drift before a retry.
      await _appMode.refreshImportStatus();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
