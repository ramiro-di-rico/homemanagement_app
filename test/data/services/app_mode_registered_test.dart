import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_platform.dart';

/// An account registered from local mode must not be forgotten if the sign-in
/// that follows fails or the app closes (SP-01).
void main() {
  late Directory directory;
  late List<LocalDatabase> opened;

  File dbFile() => File('${directory.path}/${AppModeService.activeFileName}');

  /// A real file, so that a second [AppModeService] finds what the first wrote.
  AppModeService create() => AppModeService(
    FakePlatform(PlatformType.Desktop),
    openDatabase: (_, {required mustExist}) async {
      final db = LocalDatabase(NativeDatabase(dbFile()));
      opened.add(db);
      return db;
    },
    supportDirectory: () async => directory,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('registered_');
    opened = [];
  });

  tearDown(() async {
    for (final db in opened) {
      try {
        await db.close();
      } catch (_) {}
    }
    await directory.delete(recursive: true);
  });

  test('records the account, and the move is pending from then on', () async {
    final appMode = create();
    await appMode.init();
    await appMode.enterLocalMode();
    var notified = 0;
    appMode.addListener(() => notified++);
    expect(appMode.isImportPending, isFalse);

    await appMode.markRegistered('a@b.com');

    expect(appMode.importStatus, ImportStatus.registered);
    expect(appMode.importTargetEmail, 'a@b.com');
    expect(appMode.isImportPending, isTrue);
    expect(notified, 1);
  });

  test('survives closing the app, so the email can\'t be registered again by mistake',
      () async {
    final first = create();
    await first.init();
    await first.enterLocalMode();
    await first.markRegistered('a@b.com');
    await first.database!.close();

    final second = create();
    await second.init();

    expect(second.isLocal, isTrue);
    expect(second.importStatus, ImportStatus.registered);
    expect(second.importTargetEmail, 'a@b.com');
    expect(second.isImportPending, isTrue);
  });

  test('leaving local mode is refused, which would orphan the account', () async {
    final appMode = create();
    await appMode.init();
    await appMode.enterLocalMode();
    await appMode.markRegistered('a@b.com');

    await expectLater(appMode.leaveLocalMode(), throwsStateError);

    expect(appMode.isLocal, isTrue);
  });

  test('only local mode can register for a move', () async {
    final appMode = create();
    await appMode.init();

    await expectLater(appMode.markRegistered('a@b.com'), throwsStateError);
  });

  test('a registered account with nothing to move can be switched to at once',
      () async {
    final appMode = create();
    await appMode.init();
    await appMode.enterLocalMode();
    await appMode.markRegistered('a@b.com');

    await appMode.completeImport();

    expect(appMode.isLocal, isFalse);
    expect(appMode.importTargetEmail, isNull);
    expect(appMode.importStatus, ImportStatus.notStarted);
  });
}
