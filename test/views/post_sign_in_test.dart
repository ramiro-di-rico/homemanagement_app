import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/authentication/views/user-controls-mixins/post-sign-in.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

/// `completeImport` is replaced so each test chooses its outcome without a file system.
class _AppMode extends AppModeService {
  final bool completeSucceeds;
  int completed = 0;

  _AppMode(super.platform,
      {required super.openDatabase, this.completeSucceeds = true});

  @override
  Future<void> completeImport() async {
    completed++;
    if (!completeSucceeds) throw StateError('cannot archive');
  }
}

void main() {
  late _AppMode appMode;

  Future<void> setUpMode({
    required bool local,
    bool withData = false,
    bool completeSucceeds = true,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = _AppMode(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async =>
            LocalDatabase(NativeDatabase.memory()),
        completeSucceeds: completeSucceeds);
    await appMode.init();
    if (local) {
      await appMode.enterLocalMode();
      if (withData) {
        final db = appMode.database!;
        await db.into(db.accounts).insert(AccountsCompanion.insert(
            name: 'Main', accountType: 0, currencyId: 1, measurable: const Value(true)));
      }
    }
    GetIt.I.registerSingleton<AppModeService>(appMode);
  }

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  /// Starts on a page with one button that runs [goAfterSignIn], and returns the
  /// router so a test can read where it ended up.
  Future<GoRouter> pump(WidgetTester tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
                body: TextButton(
                    onPressed: () => goAfterSignIn(context),
                    child: const Text('sign in')),
              )),
      GoRoute(
          path: HomeScreen.fullPath,
          builder: (_, __) => const Scaffold(body: Text('home'))),
      GoRoute(
          path: '/home_screen/local_import',
          builder: (_, __) => const Scaffold(body: Text('import'))),
    ]);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.tap(find.text('sign in'));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('online goes straight home', (tester) async {
    await setUpMode(local: false);

    await pump(tester);

    expect(find.text('home'), findsOneWidget);
    expect(appMode.completed, 0);
  });

  testWidgets('local with data opens the import screen', (tester) async {
    await setUpMode(local: true, withData: true);

    await pump(tester);

    expect(find.text('import'), findsOneWidget);
    expect(appMode.completed, 0, reason: 'the import itself does the switch');
  });

  testWidgets('local with only the seeds switches at once and goes home',
      (tester) async {
    await setUpMode(local: true);

    await pump(tester);

    expect(appMode.completed, 1);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a failed switch stays put and says so, without claiming a move',
      (tester) async {
    await setUpMode(local: true, completeSucceeds: false);

    await pump(tester);

    expect(appMode.completed, 1);
    expect(find.text('home'), findsNothing);
    expect(find.textContaining("couldn't switch"), findsOneWidget);
    expect(find.textContaining("move didn't finish"), findsNothing);

    await tester.tap(find.text('ok'));
    await tester.pumpAndSettle();
    expect(find.text('sign in'), findsOneWidget);
  });
}
