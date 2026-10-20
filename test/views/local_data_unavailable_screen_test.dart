import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_data_unavailable_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

void main() {
  late LocalDataUnavailableReason? failWith;
  late LocalDatabase? opened;
  late List<bool> mustExistCalls;

  Future<AppModeService> failingService() async {
    SharedPreferences.setMockInitialValues({'appMode': 'local'});
    final service = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async {
      mustExistCalls.add(mustExist);
      final reason = failWith;
      if (reason != null) throw LocalDataUnavailableException(reason);
      return opened = LocalDatabase(NativeDatabase.memory());
    });
    await service.init();
    return service;
  }

  Widget host(AppModeService service) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocalDataUnavailableScreen(appModeService: service),
      );

  setUp(() {
    failWith = LocalDataUnavailableReason.keyMissing;
    opened = null;
    mustExistCalls = [];
  });

  tearDown(() async => opened?.close());

  final retry = find.text('Retry');
  final online = find.text('Use an online account instead');
  final startEmpty = find.text('Start with empty data');

  testWidgets('a lost key explains that the data is kept, and offers no retry', (tester) async {
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.text("Your local data can't be opened"), findsOneWidget);
    expect(find.textContaining('key that protects your local data is gone'), findsOneWidget);
    expect(find.textContaining('nothing was deleted'), findsOneWidget);
    expect(retry, findsNothing, reason: 'a lost key can never come back');
    expect(online, findsOneWidget);
    expect(startEmpty, findsNothing);
    expect(find.textContaining(RegExp('delete my|reset', caseSensitive: false)), findsNothing);
  });

  testWidgets('a locked credential store is the one case that says to unlock it', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.textContaining('credential store'), findsOneWidget);
    expect(retry, findsOneWidget);
    expect(online, findsOneWidget);
  });

  testWidgets('an unreadable file can be retried, and says it was kept', (tester) async {
    failWith = LocalDataUnavailableReason.unreadable;
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.textContaining("can't be read. It was kept"), findsOneWidget);
    expect(retry, findsOneWidget);
    expect(startEmpty, findsNothing);
  });

  testWidgets('a missing file offers retry and, as an explicit choice, empty data', (tester) async {
    failWith = LocalDataUnavailableReason.fileMissing;
    final service = await failingService();
    await tester.pumpWidget(host(service));

    expect(find.textContaining("wasn't found"), findsOneWidget);
    expect(retry, findsOneWidget);
    expect(startEmpty, findsOneWidget);
    expect(online, findsOneWidget);
    expect(opened, isNull, reason: 'nothing was created on its own');
  });

  testWidgets('starting with empty data opens a new database, only when asked', (tester) async {
    failWith = LocalDataUnavailableReason.fileMissing;
    final service = await failingService();
    await tester.pumpWidget(host(service));
    failWith = null;

    await tester.tap(startEmpty);
    await tester.pumpAndSettle();

    expect(service.startupError, isNull);
    expect(service.database, isNotNull);
    expect(mustExistCalls, [true, false], reason: 'the explicit action is the one that may create');
  });

  testWidgets('Retry runs init again and clears the error when it works', (tester) async {
    failWith = LocalDataUnavailableReason.unreadable;
    final service = await failingService();
    await tester.pumpWidget(host(service));
    expect(service.startupError, isNotNull);

    failWith = null;
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(service.startupError, isNull);
    expect(service.database, isNotNull);
  });

  testWidgets('a Retry that fails again says so', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    final service = await failingService();
    await tester.pumpWidget(host(service));

    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(find.text("Still can't open your local data."), findsOneWidget);
    expect(service.startupError, isNotNull);
  });

  testWidgets('using an online account instead leaves local mode and keeps the data', (tester) async {
    final service = await failingService();
    await tester.pumpWidget(host(service));

    await tester.tap(online);
    await tester.pumpAndSettle();

    expect(service.isLocal, isFalse);
    expect(service.startupError, isNull);
    expect((await SharedPreferences.getInstance()).getString('appMode'), 'online');
  });
}
