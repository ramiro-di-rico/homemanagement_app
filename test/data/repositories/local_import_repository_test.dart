import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/models/import_mismatch.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/models/import_result.dart';
import 'package:home_management_app/data/repositories/local_import.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/local_import.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/sources/import_currency_missing_exception.dart';
import 'package:home_management_app/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

class _Auth implements AuthenticationService {
  @override
  UserModel? user = UserModel('a@b.com', '', '', '', '', DateTime(2030), false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Stands in for the real import: [LocalImportService]'s dependencies are never
/// reached because [run] is replaced.
class _StubService implements LocalImportService {
  final LocalDatabase database;
  final Future<ImportResult> Function(String email, ImportProgress? onProgress)
  body;
  final List<String> emails = [];

  _StubService(this.database, this.body);

  @override
  Future<ImportResult> run({
    required String email,
    ImportProgress? onProgress,
  }) {
    emails.add(email);
    return body(email, onProgress);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory directory;
  late AppModeService appMode;
  late _Auth auth;
  late _StubService service;
  late LocalImportRepository repository;

  Future<void> setStatus(ImportStatus status) {
    // Read each time: the app mode replaces the database object when it reopens.
    final db = appMode.database!;
    return (db.update(db.importStates)..where((s) => s.id.equals(1))).write(
      ImportStatesCompanion(status: Value(status)),
    );
  }

  /// Builds the repository around a service whose `run` is [body].
  void build(Future<ImportResult> Function(String, ImportProgress?) body) {
    repository = LocalImportRepository(
      appMode: appMode,
      authentication: auth,
      createService: (db) => service = _StubService(db, body),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('import_repository_');
    appMode = AppModeService(
      FakePlatform(PlatformType.Desktop),
      openDatabase: (_, {required mustExist}) async =>
          LocalDatabase(NativeDatabase.memory()),
      supportDirectory: () async => directory,
    );
    await appMode.init();
    await appMode.enterLocalMode();
    await File(
      '${directory.path}/${AppModeService.activeFileName}',
    ).writeAsString('x');
    auth = _Auth();
  });

  tearDown(() async {
    await appMode.database?.close();
    await directory.delete(recursive: true);
  });

  test(
    'a successful import reports progress, then archives and goes online',
    () async {
      final seen = <(ImportStep?, int, int)>[];
      build((email, onProgress) async {
        await setStatus(ImportStatus.inProgress);
        onProgress!(ImportStep.accounts, 1, 2);
        seen.add((
          repository.step,
          repository.progress.$1,
          repository.progress.$2,
        ));
        onProgress(ImportStep.verifying, 2, 2);
        await setStatus(ImportStatus.completed);
        return ImportResult([ImportMismatch('Main', 10, 12)]);
      });
      expect(repository.status, ImportStatus.notStarted);

      await repository.start();

      expect(service.emails, ['a@b.com']);
      expect(seen.single, (ImportStep.accounts, 1, 2));
      expect(repository.status, ImportStatus.completed);
      expect(repository.error, isNull);
      expect(repository.isRunning, isFalse);
      expect(repository.mismatches.single.accountName, 'Main');
      expect(appMode.isLocal, isFalse, reason: 'completeImport ran');
    },
  );

  test('local writes are locked while it runs', () async {
    final gate = Completer<void>();
    build((email, onProgress) async {
      await setStatus(ImportStatus.inProgress);
      onProgress!(ImportStep.preflight, 0, 1);
      await gate.future;
      await setStatus(ImportStatus.completed);
      return ImportResult([]);
    });

    final running = repository.start();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.isRunning, isTrue);
    expect(repository.status, ImportStatus.inProgress);
    expect(appMode.isImportPending, isTrue);

    gate.complete();
    await running;
  });

  test('a failure is kept, the lock stays, and nothing is archived', () async {
    build((email, onProgress) async {
      await setStatus(ImportStatus.failed);
      throw ImportCurrencyMissingException(['EUR']);
    });

    await repository.start();

    expect(repository.status, ImportStatus.failed);
    expect(repository.error, isA<ImportCurrencyMissingException>());
    expect(appMode.isLocal, isTrue);
    expect(appMode.isImportPending, isTrue);
    expect(
      await File('${directory.path}/${AppModeService.activeFileName}').exists(),
      isTrue,
    );
  });

  test('resume runs again after a failure and can finish', () async {
    var attempt = 0;
    build((email, onProgress) async {
      attempt++;
      if (attempt == 1) {
        await setStatus(ImportStatus.failed);
        throw Exception('connection lost');
      }
      await setStatus(ImportStatus.completed);
      return ImportResult([]);
    });
    await repository.start();
    expect(repository.status, ImportStatus.failed);

    await repository.resume();

    expect(repository.status, ImportStatus.completed);
    expect(repository.error, isNull, reason: 'the old error is cleared');
    expect(appMode.isLocal, isFalse);
  });

  test('a second call while it runs does nothing', () async {
    final gate = Completer<void>();
    var calls = 0;
    build((email, onProgress) async {
      calls++;
      await gate.future;
      await setStatus(ImportStatus.completed);
      return ImportResult([]);
    });

    final first = repository.start();
    await repository.start();
    await repository.resume();
    gate.complete();
    await first;

    expect(calls, 1);
  });

  test(
    'without a signed-in user it fails and never calls the service',
    () async {
      auth.user = null;
      build((email, onProgress) async => ImportResult([]));

      await repository.start();

      expect(repository.status, ImportStatus.failed);
      expect(repository.error, isA<StateError>());
      expect(appMode.isLocal, isTrue);
    },
  );

  test('if archiving fails after the import finished, writes stay locked and a '
      'retry archives without sending again', () async {
    // Root ignores directory permissions, so the failure can't be forced there.
    if ((await Process.run('id', ['-u'])).stdout.toString().trim() == '0') {
      markTestSkipped('running as root');
      return;
    }
    // A real file, so that the reopened database still has what was written.
    await appMode.database!.close();
    appMode = AppModeService(
      FakePlatform(PlatformType.Desktop),
      openDatabase: (name, {required mustExist}) async =>
          LocalDatabase(NativeDatabase(File('${directory.path}/$name'))),
      supportDirectory: () async => directory,
    );
    await appMode.init();
    await appMode.enterLocalMode();
    var runs = 0;
    build((email, onProgress) async {
      runs++;
      await setStatus(ImportStatus.completed);
      // Only now, so archiving is what fails: the service has written its status.
      if (runs == 1) await Process.run('chmod', ['555', directory.path]);
      return ImportResult([]);
    });
    addTearDown(() => Process.run('chmod', ['755', directory.path]));

    await repository.start();

    expect(repository.status, ImportStatus.failed);
    expect(repository.error, isA<FileSystemException>());
    expect(appMode.isLocal, isTrue);
    expect(
      appMode.isImportPending,
      isTrue,
      reason: 'the data was already sent, so nothing new may be written',
    );

    await Process.run('chmod', ['755', directory.path]);
    await repository.resume();

    expect(repository.status, ImportStatus.completed);
    expect(appMode.isLocal, isFalse);
    expect(
      runs,
      2,
      reason: 'the service ran again, and it skips what was sent',
    );
  });

  test('a new local session does not inherit the last import', () async {
    build((email, onProgress) async {
      await setStatus(ImportStatus.completed);
      return ImportResult([ImportMismatch('Main', 10, 12)]);
    });
    await repository.start();
    expect(repository.status, ImportStatus.completed);
    expect(repository.mismatches, isNotEmpty);

    await Future<void>.delayed(Duration.zero);
    expect(
      repository.mismatches,
      isNotEmpty,
      reason: 'the summary stays while the app is online',
    );

    await appMode.enterLocalMode();

    expect(repository.status, ImportStatus.notStarted);
    expect(repository.mismatches, isEmpty);
    expect(repository.error, isNull);
    expect(repository.step, isNull);
    expect(repository.progress, (0, 0));
  });

  test('an error from the last session is cleared by the next one', () async {
    build((email, onProgress) async {
      await setStatus(ImportStatus.failed);
      throw Exception('boom');
    });
    await repository.start();
    expect(repository.error, isNotNull);
    await setStatus(ImportStatus.notStarted);
    await appMode.refreshImportStatus();
    await appMode.enterLocalMode();

    expect(repository.error, isNull);
    expect(repository.status, ImportStatus.notStarted);
  });
}
