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
  late Duration openingTime;
  late int opens;

  AppModeService createAppMode(PlatformType type) => AppModeService(
        FakePlatform(type),
        openDatabase: (_, {required mustExist}) async {
          opens++;
          await Future.delayed(openingTime);
          final reason = failWith;
          if (reason != null) throw LocalDataUnavailableException(reason);
          final db = LocalDatabase(NativeDatabase.memory());
          opened.add(db);
          return db;
        },
      );

  Future<GoRouter> pumpLogin(WidgetTester tester, AppModeService appMode, {String? initialEmail}) async {
    GetIt.I.registerSingleton(appMode);
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: LoginView.fullPath,
      routes: [
        GoRoute(path: LoginView.fullPath, builder: (_, _) => DesktopLoginView(initialEmail: initialEmail)),
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
    openingTime = Duration.zero;
    opens = 0;
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

  testWidgets('a second click while it is opening does nothing, and the button shows it is busy', (tester) async {
    openingTime = const Duration(milliseconds: 300);
    final appMode = createAppMode(PlatformType.Desktop);
    final router = await pumpLogin(tester, appMode);

    await tester.tap(find.text(buttonLabel));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, buttonLabel)).onPressed, isNull,
        reason: 'disabled while it opens');
    await tester.tap(find.text(buttonLabel), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(opens, 1);
    expect(appMode.isLocal, isTrue);
    expect(find.text('LOCAL HOME'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.path, HomeScreen.fullPath);
  });

  testWidgets('after a failure the button works again', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    await pumpLogin(tester, createAppMode(PlatformType.Desktop));
    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, buttonLabel)).onPressed, isNotNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('an unavailable keyring shows a dialog and stays on the login', (tester) async {
    failWith = LocalDataUnavailableReason.keyringUnavailable;
    final appMode = createAppMode(PlatformType.Desktop);
    final router = await pumpLogin(tester, appMode);

    await tester.tap(find.text(buttonLabel));
    await tester.pumpAndSettle();

    expect(find.text('Local mode unavailable'), findsOneWidget);
    expect(find.textContaining('credential store'), findsOneWidget);
    expect(appMode.isLocal, isFalse);
    expect(router.routerDelegate.currentConfiguration.uri.path, LoginView.fullPath);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Local mode unavailable'), findsNothing);
  });

  group('continuing a move for an account that was already registered', () {
    testWidgets('the email is already typed in', (tester) async {
      await pumpLogin(tester, createAppMode(PlatformType.Desktop), initialEmail: 'a@b.com');

      expect(find.widgetWithText(TextField, 'a@b.com'), findsOneWidget);
    });

    testWidgets('so only the password is left to type before signing in', (tester) async {
      await pumpLogin(tester, createAppMode(PlatformType.Desktop), initialEmail: 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'secret-123');
      await tester.pump();

      final signIn = find.widgetWithIcon(ElevatedButton, Icons.send);
      expect(tester.widget<ElevatedButton>(signIn).onPressed, isNotNull);
    });

    testWidgets('without one, the field starts empty and sign-in stays disabled', (tester) async {
      await pumpLogin(tester, createAppMode(PlatformType.Desktop));
      await tester.enterText(find.byType(TextField).at(1), 'secret-123');
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text, isEmpty);
      expect(find.widgetWithIcon(ElevatedButton, Icons.send), findsNothing,
          reason: 'the filled sign-in button only appears with a valid email and password');
    });
  });
}
