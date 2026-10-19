import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/ui/features/authentication/views/login-desktop.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

void main() {
  const buttonLabel = 'Use without an account';
  late List<LocalDatabase> opened;
  late LocalDataUnavailableReason? failWith;

  AppModeService createAppMode(PlatformType type) => AppModeService(
        FakePlatform(type),
        openDatabase: (_) async {
          final reason = failWith;
          if (reason != null) throw LocalDataUnavailableException(reason);
          final db = LocalDatabase(NativeDatabase.memory());
          opened.add(db);
          return db;
        },
      );

  Future<GoRouter> pumpLogin(WidgetTester tester, AppModeService appMode) async {
    GetIt.I.registerSingleton(appMode);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: LoginView.fullPath,
      routes: [
        GoRoute(path: LoginView.fullPath, builder: (_, _) => const DesktopLoginView()),
        GoRoute(path: HomeScreen.fullPath, builder: (_, _) => const Text('LOCAL HOME')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    return router;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    opened = [];
    failWith = null;
    await GetIt.I.reset();
    // Everything the login view needs apart from the app mode, which each test registers.
    final platform = PlatformStrategy.createPlatform();
    registerDependencies(platform, appModeService: createAppMode(PlatformType.Desktop));
    GetIt.I.unregister<AppModeService>();
  });

  tearDown(() async {
    for (final db in opened) {
      await db.close();
    }
    await GetIt.I.reset();
  });

  testWidgets('shows the option on desktop', (tester) async {
    await pumpLogin(tester, createAppMode(PlatformType.Desktop));

    expect(find.text(buttonLabel), findsOneWidget);
  });

  for (final type in [PlatformType.Web, PlatformType.WebMobile, PlatformType.Mobile]) {
    testWidgets('hides the option on ${type.name}', (tester) async {
      await pumpLogin(tester, createAppMode(type));

      expect(find.text(buttonLabel), findsNothing);
    });
  }

  testWidgets('tapping it enters local mode and opens the home', (tester) async {
    final appMode = createAppMode(PlatformType.Desktop);
    final router = await pumpLogin(tester, appMode);

    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();

    expect(appMode.isLocal, isTrue);
    expect(appMode.database, isNotNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, HomeScreen.fullPath);
    expect(find.text('LOCAL HOME'), findsOneWidget);
  });

  testWidgets('an unavailable keyring shows a dialog and stays on the login', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    final appMode = createAppMode(PlatformType.Desktop);
    final router = await pumpLogin(tester, appMode);

    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();

    expect(find.text('Local mode unavailable'), findsOneWidget);
    expect(find.textContaining('system keyring'), findsOneWidget);
    expect(appMode.isLocal, isFalse);
    expect(router.routerDelegate.currentConfiguration.uri.path, LoginView.fullPath);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Local mode unavailable'), findsNothing);
  });
}
