import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
import 'package:home_management_app/data/services/sources/import_wrong_user_exception.dart';
import 'package:home_management_app/domain/models/user.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_import_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

class _Auth implements AuthenticationService {
  @override
  UserModel? user = UserModel('a@b.com', '', '', '', '', DateTime(2030), false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service implements LocalImportService {
  final Future<ImportResult> Function(ImportProgress? onProgress) body;
  int runs = 0;

  _Service(this.body);

  @override
  Future<ImportResult> run({
    required String email,
    ImportProgress? onProgress,
  }) {
    runs++;
    return body(onProgress);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory directory;
  late AppModeService appMode;
  late LocalImportRepository repository;
  late _Service service;

  Future<void> setStatus(ImportStatus status) async {
    final db = appMode.database!;
    await (db.update(db.importStates)..where((s) => s.id.equals(1))).write(
      ImportStatesCompanion(status: Value(status)),
    );
    await appMode.refreshImportStatus();
  }

  /// A service whose outcome the test decides. Like the real one, it stores the
  /// status before it returns or throws.
  Future<ImportResult> finish(List<ImportMismatch> mismatches) async {
    await setStatus(ImportStatus.completed);
    return ImportResult(mismatches);
  }

  Future<Never> fail(Object error) async {
    await setStatus(ImportStatus.failed);
    throw error;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    directory = await Directory.systemTemp.createTemp('import_screen_');
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
  });

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
    await directory.delete(recursive: true);
  });

  /// Builds the repository around [body], then shows the screen.
  Future<void> pumpScreen(
    WidgetTester tester,
    Future<ImportResult> Function(ImportProgress? onProgress) body,
  ) async {
    service = _Service(body);
    repository = LocalImportRepository(
      appMode: appMode,
      authentication: _Auth(),
      createService: (_) => service,
    );
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton<LocalImportRepository>(repository);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: LocalImportScreen.fullPath,
      routes: [
        GoRoute(
          path: LocalImportScreen.fullPath,
          builder: (_, __) => const LocalImportScreen(),
        ),
        GoRoute(
          path: HomeScreen.fullPath,
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();
  }

  /// Lets real async work (files, the database) finish while a test is faked:
  /// real time passes, then the faked microtasks it unblocked run, and so on.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
      if (!repository.isRunning) break;
    }
    await tester.pump();
  }

  testWidgets('starts by itself, shows the step it is on, then the summary', (
    tester,
  ) async {
    final gate = Completer<void>();
    await pumpScreen(tester, (onProgress) async {
      await setStatus(ImportStatus.inProgress);
      onProgress!(ImportStep.accounts, 1, 3);
      await gate.future;
      return finish([]);
    });
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(service.runs, 1);
    expect(
      find.text('Moving your data to your online account'),
      findsOneWidget,
    );
    expect(find.text('Moving accounts'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    gate.complete();
    await settle(tester);

    expect(
      find.text('Your data is now in your online account.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('lists every account whose balance differs (FR-023)', (
    tester,
  ) async {
    await pumpScreen(tester, (onProgress) async {
      await setStatus(ImportStatus.inProgress);
      return finish([
        ImportMismatch('Savings', 10, 12.5),
        ImportMismatch('Cash', 1, 2),
      ]);
    });
    await settle(tester);

    expect(
      find.text(
        "The balance of Savings doesn't match: 10.00 here, 12.50 online.",
      ),
      findsOneWidget,
    );
    expect(
      find.text("The balance of Cash doesn't match: 1.00 here, 2.00 online."),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets(
    'a failure keeps the app local, says why, and Retry runs it again',
    (tester) async {
      var attempt = 0;
      await pumpScreen(tester, (onProgress) async {
        attempt++;
        if (attempt == 1) await fail(Exception('connection lost'));
        return finish([]);
      });
      await settle(tester);

      expect(find.textContaining("The move didn't finish"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(appMode.isLocal, isTrue);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await settle(tester);

      expect(service.runs, 2);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    },
  );

  testWidgets('a missing currency names the currencies', (tester) async {
    await pumpScreen(
      tester,
      (onProgress) => fail(ImportCurrencyMissingException(['EUR', 'GBP'])),
    );
    await settle(tester);

    expect(find.textContaining('EUR, GBP'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('another user is told which account finishes the move', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      (onProgress) => fail(ImportWrongUserException('first@b.com')),
    );
    await settle(tester);

    expect(
      find.text(
        'The move was started for first@b.com. Sign in with that account to finish it.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'after a failure and a restart it waits for Retry instead of starting',
    (tester) async {
      await setStatus(ImportStatus.failed);
      await pumpScreen(tester, (onProgress) async => finish([]));
      await tester.pump();

      expect(service.runs, 0);
      expect(find.text('Retry'), findsOneWidget);
    },
  );

  testWidgets('a restart in the middle of a move resumes it', (tester) async {
    await setStatus(ImportStatus.inProgress);
    await pumpScreen(tester, (onProgress) async => finish([]));
    await settle(tester);

    expect(service.runs, 1);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('a finished import that was not archived is finished on open', (
    tester,
  ) async {
    await setStatus(ImportStatus.completed);
    await pumpScreen(tester, (onProgress) async => finish([]));
    await settle(tester);

    expect(service.runs, 1);
    expect(appMode.isLocal, isFalse);
  });

  testWidgets('online, it only shows the summary and starts nothing', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      (onProgress) async => finish([ImportMismatch('Cash', 1, 2)]),
    );
    await settle(tester);
    expect(appMode.isLocal, isFalse);
    expect(service.runs, 1);

    // Opened again later, with the same repository, e.g. by navigating back.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocalImportScreen(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(service.runs, 1, reason: 'nothing started again');
    expect(
      find.text('Your data is now in your online account.'),
      findsOneWidget,
    );
    expect(find.textContaining('Cash'), findsOneWidget);
  });
}
