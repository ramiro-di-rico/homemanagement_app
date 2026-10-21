import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

void main() {
  late Directory directory;
  late AppModeService appMode;
  late List<LocalDatabase> opened;

  File active() => File('${directory.path}/${AppModeService.activeFileName}');
  File named(String name) => File('${directory.path}/$name');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('complete_import_');
    opened = [];
    // The opener is faked with an in-memory database. The file on disk stands in
    // for the real encrypted one, which is all that completeImport touches.
    appMode = AppModeService(
      FakePlatform(PlatformType.Desktop),
      openDatabase: (_, {required mustExist}) async {
        final db = LocalDatabase(NativeDatabase.memory());
        opened.add(db);
        return db;
      },
      supportDirectory: () async => directory,
      now: () => DateTime(2026, 10, 21, 15),
    );
    await appMode.init();
    await appMode.enterLocalMode();
    await active().writeAsString('local data');
  });

  tearDown(() async {
    for (final db in opened) {
      try {
        await db.close();
      } catch (_) {}
    }
    await directory.delete(recursive: true);
  });

  test('archives the file under a dated name and goes online', () async {
    var notified = 0;
    appMode.addListener(() => notified++);

    await appMode.completeImport();

    expect(appMode.isLocal, isFalse);
    expect(appMode.database, isNull);
    expect(await active().exists(), isFalse);
    final backup = named('homemanagement_local.backup-2026-10-21.sqlite');
    expect(await backup.readAsString(), 'local data');
    expect(notified, 1);
    expect(
      (await SharedPreferences.getInstance()).getString('appMode'),
      'online',
    );
  });

  test('adds -N when that day already has a backup', () async {
    await named(
      'homemanagement_local.backup-2026-10-21.sqlite',
    ).writeAsString('first');
    await named(
      'homemanagement_local.backup-2026-10-21-1.sqlite',
    ).writeAsString('second');

    await appMode.completeImport();

    final third = named('homemanagement_local.backup-2026-10-21-2.sqlite');
    expect(await third.readAsString(), 'local data');
    expect(
      await named(
        'homemanagement_local.backup-2026-10-21.sqlite',
      ).readAsString(),
      'first',
    );
  });

  test('moves SQLite side files along with the database', () async {
    await File('${active().path}-wal').writeAsString('wal');

    await appMode.completeImport();

    expect(await File('${active().path}-wal').exists(), isFalse);
    expect(
      await named(
        'homemanagement_local.backup-2026-10-21.sqlite-wal',
      ).readAsString(),
      'wal',
    );
  });

  test(
    'the next local session starts with no file, so it starts fresh',
    () async {
      await appMode.completeImport();
      opened.clear();

      await appMode.enterLocalMode();

      expect(appMode.isLocal, isTrue);
      expect(
        await active().exists(),
        isFalse,
        reason: 'the opener makes a new one',
      );
      expect(opened, hasLength(1));
      expect(appMode.isImportPending, isFalse);
    },
  );

  test('refuses to run outside local mode', () async {
    await appMode.leaveLocalMode();

    await expectLater(appMode.completeImport(), throwsStateError);
  });

  test(
    'a file that can\'t be renamed leaves the app in local mode with its data',
    () async {
      // Root ignores directory permissions, so the failure can't be forced there.
      if ((await Process.run('id', ['-u'])).stdout.toString().trim() == '0') {
        markTestSkipped('running as root');
        return;
      }
      await Process.run('chmod', ['555', directory.path]);
      addTearDown(() => Process.run('chmod', ['755', directory.path]));
      opened.clear();

      await expectLater(
        appMode.completeImport(),
        throwsA(isA<FileSystemException>()),
      );

      expect(appMode.isLocal, isTrue);
      expect(
        appMode.database,
        isNotNull,
        reason: 'reopened, so the app still works',
      );
      expect(opened, hasLength(1));
      expect(await active().exists(), isTrue);
      expect(
        (await SharedPreferences.getInstance()).getString('appMode'),
        'local',
      );
    },
  );

  Future<void> setStatus(ImportStatus status) {
    final db = appMode.database!;
    return (db.update(db.importStates)..where((s) => s.id.equals(1))).write(
      ImportStatesCompanion(status: Value(status)),
    );
  }

  for (final status in [ImportStatus.inProgress, ImportStatus.failed]) {
    test('refuses to archive an import that is ${status.name}', () async {
      await setStatus(status);

      await expectLater(appMode.completeImport(), throwsStateError);

      expect(appMode.isLocal, isTrue);
      expect(appMode.database, isNotNull);
      expect(await active().exists(), isTrue, reason: 'nothing was renamed');
      expect(appMode.isImportPending, isTrue);
    });
  }

  test('archives a finished import, reading the stored status', () async {
    // The service wrote `completed`; the app mode has not been told yet.
    await setStatus(ImportStatus.completed);

    await appMode.completeImport();

    expect(appMode.isLocal, isFalse);
    expect(await active().exists(), isFalse);
  });

  test('a completed status that is still local counts as pending', () async {
    await setStatus(ImportStatus.completed);
    await appMode.refreshImportStatus();

    expect(appMode.isImportPending, isTrue);
    await expectLater(appMode.leaveLocalMode(), throwsStateError);
  });
}
