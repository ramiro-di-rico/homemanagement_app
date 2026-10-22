import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/models/import_result.dart';
import 'package:home_management_app/data/repositories/local_import.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/local_import.service.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/myapp.dart';
import 'package:home_management_app/ui/features/home/views/home-desktop.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_home_desktop.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

/// Stands in for the move itself, so the journey around it is what is tested.
class _Move implements LocalImportService {
  final LocalDatabase db;
  _Move(this.db);

  @override
  Future<ImportResult> run({required String email, ImportProgress? onProgress}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await (db.update(db.importStates)..where((s) => s.id.equals(1)))
        .write(const ImportStatesCompanion(status: Value(ImportStatus.completed)));
    return ImportResult([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// What one run of the journey produced.
class _Journey {
  final List<String> errors = [];
  final List<String> requests = [];
  final List<String> routes = [];
  final List<String> timeline = [];
  late AppModeService appMode;
  late Directory folder;
  bool homeBeneathImport = false;
  bool continueShown = false;
  int _tick = 0;

  void note(String what) => timeline.add('${(_tick++).toString().padLeft(3)} $what');

  /// Errors that are not just the fake server or the test environment.
  List<String> get real => [
        for (final e in errors)
          if (!e.contains('app_links') && !e.contains("is not a subtype of type 'Map<String, dynamic>'")) e,
      ];

  String get report => 'TIMELINE\n${timeline.join('\n')}\nREQUESTS\n${requests.join('\n')}';
}

void main() {
  /// Local home → "Create online account" → sign-up → the move → the online home,
  /// with the real app, router and services. Only the network and the move are faked.
  Future<_Journey> runJourney(WidgetTester tester,
      {required Size size}) async {
    final journey = _Journey();
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString().split('\n').first;
      journey.note('ERROR $text');
      if (text.contains('overflowed')) {
        final all = details.toString();
        final at = all.indexOf('relevant error-causing widget');
        journey.note('      ${all.substring(at, at + 260).replaceAll('\n', ' ')}');
      }
      journey.errors.add(text);
    };

    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    final folder = journey.folder = Directory.systemTemp.createTempSync('journey_');
    addTearDown(() => folder.deleteSync(recursive: true));
    File('${folder.path}/${AppModeService.activeFileName}').writeAsStringSync('local data');
    final appMode = journey.appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => LocalDatabase(NativeDatabase.memory()),
        supportDirectory: () async => folder);
    await appMode.init();
    await appMode.enterLocalMode();
    final db = appMode.database!;
    await db.into(db.accounts).insert(
        AccountsCompanion.insert(name: 'Main', accountType: 0, currencyId: 1));

    final client = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      journey.requests.add('${request.method} ${request.url.path} auth=${request.headers['Authorization'] ?? '-'}');
      if (request.url.path.endsWith('/registration')) return http.Response('', 200);
      if (request.url.path.contains('Authentication/SignIn')) {
        return http.Response(
            jsonEncode({
              'email': 'new@user.com',
              'username': 'new@user.com',
              'token': 'token-1',
              'refreshToken': 'refresh-1',
              'expirationDate':
                  DateTime.now().toUtc().add(const Duration(hours: 1)).toIso8601String(),
              'twoFactorRequired': false,
            }),
            200);
      }
      return http.Response('[]', 200);
    });

    try {
      await http.runWithClient(() async {
        final platform = PlatformStrategy.createPlatform();
        registerDependencies(platform, appModeService: appMode);
        appMode.addListener(() => journey.note(
            'appMode: isLocal=${appMode.isLocal} db=${appMode.database != null} status=${appMode.importStatus.name}'));
        GetIt.I.unregister<LocalImportRepository>();
        GetIt.I.registerSingleton(LocalImportRepository(
            appMode: appMode,
            authentication: GetIt.I<AuthenticationService>(),
            createService: (database) => _Move(database)));

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MyApp(platform));
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
        void noteRoute() {
          final uri = router.routerDelegate.currentConfiguration.uri.toString();
          journey.routes.add(uri);
          journey.note('route -> $uri');
        }

        router.routerDelegate.addListener(noteRoute);
        journey.routes.add(router.routerDelegate.currentConfiguration.uri.toString());

        journey.note('TAP create online account');
        await tester.tap(find.text('Create online account').first);
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        await tester.enterText(find.byType(TextField).at(0), 'new@user.com');
        await tester.pump();
        await tester.enterText(find.byType(TextField).at(1), 'Str0ng-Passw0rd');
        await tester.pump();
        journey.note('TAP send');
        await tester.tap(find.byIcon(Icons.send));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        // The home must not be hiding beneath the import screen.
        journey.homeBeneathImport = find.byType(LocalHomeDesktop, skipOffstage: false).evaluate().isNotEmpty ||
            find.byType(HomeDesktop, skipOffstage: false).evaluate().isNotEmpty;

        // Let the move finish: archiving the file is real I/O, which the fake clock
        // doesn't advance.
        for (var i = 0; i < 40 && GetIt.I<LocalImportRepository>().isRunning; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
          await tester.pump(const Duration(milliseconds: 100));
        }
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        journey.note('STATE after the move: location=${router.routerDelegate.currentConfiguration.uri}');

        journey.note('STATE at the end: location=${router.routerDelegate.currentConfiguration.uri} continue=${find.text('Continue').evaluate().length}');
        journey.continueShown = find.text('Continue').evaluate().isNotEmpty;
      }, () => client);
    } finally {
      // Before any expect(), or a failure is reported as a harness assertion.
      FlutterError.onError = previous;
      await appMode.database?.close();
    }
    return journey;
  }

  const forbidden = [
    'setState() called after dispose',
    'Local database is not open',
    'Null check operator',
    'overflowed',
    'markNeedsBuild() called during build',
  ];

  testWidgets('creating the online account goes straight to the move, and the move ends online',
      (tester) async {
    final j = await runJourney(tester, size: const Size(1400, 900));

    expect(j.routes, isNot(contains(startsWith('/login_screen'))),
        reason: 'the sign-in is still running: the router must not move the screen\n${j.report}');
    expect(j.routes, containsAllInOrder(['/home_screen', '/registration_screen', '/local_import']),
        reason: j.report);
    expect(j.routes.last, '/local_import', reason: 'it stays on the summary until Continue\n${j.report}');
    expect(j.homeBeneathImport, isFalse,
        reason: 'a home page under the import screen is built when the move ends\n${j.report}');
    expect(j.appMode.isLocal, isFalse, reason: j.report);
    expect(j.continueShown, isTrue, reason: j.report);
    expect(j.folder.listSync().map((f) => f.path.split('/').last).where((n) => n.contains('.backup-')),
        hasLength(1),
        reason: 'the local file is kept as a backup');

    for (final pattern in forbidden) {
      expect(j.errors.where((e) => e.contains(pattern)), isEmpty,
          reason: '"$pattern" is back\n${j.report}');
    }
    expect(j.real, isEmpty, reason: 'unexpected errors\n${j.report}');
  });

  testWidgets('it signs in once, and loads nothing from the server before Continue', (tester) async {
    final j = await runJourney(tester, size: const Size(1400, 900));

    expect(j.requests, hasLength(2), reason: j.report);
    expect(j.requests[0], startsWith('POST /identity/api/registration'));
    expect(j.requests[1], startsWith('POST /identity/api/Authentication/SignIn'),
        reason: 'signed in once, right after registering');
    expect(j.requests.where((r) => r.contains('/homemanagementapi/')), isEmpty,
        reason: 'the online home used to load everything underneath the import screen\n${j.report}');
  });

  testWidgets('in a narrow window the screens of the move still fit', (tester) async {
    final j = await runJourney(tester, size: const Size(420, 900));

    expect(j.errors.where((e) => e.contains('overflowed')), isEmpty, reason: j.report);
    expect(j.routes, contains('/local_import'), reason: j.report);
  });
}
