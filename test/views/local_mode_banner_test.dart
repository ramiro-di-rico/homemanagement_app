import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:home_management_app/ui/features/home/views/logging_view.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_mode_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

void main() {
  late AppModeService appMode;

  Future<void> setUpMode({required bool local}) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async => LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    if (local) await appMode.enterLocalMode();
    GetIt.I.registerSingleton<AppModeService>(appMode);
  }

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<GoRouter> pump(WidgetTester tester, Widget home, {ThemeData? theme}) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(path: RegistrationScreen.fullPath, builder: (_, _) => const Text('REGISTRATION SCREEN')),
    ]);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: theme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    return router;
  }

  Widget pageWithBanner() => Scaffold(
        appBar: AppBar(title: const Text('Page'), bottom: const LocalModeBanner()),
        body: const Text('BODY'),
      );

  group('in local mode', () {
    setUp(() => setUpMode(local: true));

    testWidgets('says so and offers to create an online account', (tester) async {
      await pump(tester, pageWithBanner());

      expect(find.text("You're working locally on this computer"), findsOneWidget);
      expect(find.text('Create online account'), findsOneWidget);
      expect(find.text('BODY'), findsOneWidget);
    });

    testWidgets('sits under the title and takes its own height', (tester) async {
      await pump(tester, pageWithBanner());

      final appBar = tester.getRect(find.byType(AppBar));
      final banner = tester.getRect(find.byType(LocalModeBanner));
      expect(banner.bottom, appBar.bottom, reason: 'it is the bottom of the app bar');
      expect(banner.height, 48);
      expect(tester.getTopLeft(find.text('BODY')).dy, greaterThanOrEqualTo(appBar.bottom));
    });

    testWidgets('the button opens registration', (tester) async {
      await pump(tester, pageWithBanner());

      await tester.tap(find.text('Create online account'));
      await tester.pumpAndSettle();

      expect(find.text('REGISTRATION SCREEN'), findsOneWidget);
    });

    for (final (name, theme) in [('light', ThemeData.light()), ('dark', ThemeData.dark())]) {
      testWidgets('uses the $name theme colours', (tester) async {
        await pump(tester, pageWithBanner(), theme: theme);
        final scheme = Theme.of(tester.element(find.byType(LocalModeBanner))).colorScheme;

        final background = tester.widget<Material>(
            find.descendant(of: find.byType(LocalModeBanner), matching: find.byType(Material)).first);
        final text = tester.widget<Text>(find.text("You're working locally on this computer"));

        expect(background.color, scheme.secondaryContainer);
        expect(text.style?.color, scheme.onSecondaryContainer);
      });
    }

    testWidgets('is on the log screen too', (tester) async {
      await pump(tester, const LoggingView());

      expect(find.byType(LocalModeBanner), findsOneWidget);
      expect(find.text("You're working locally on this computer"), findsOneWidget);
    });
  });

  group('online', () {
    setUp(() => setUpMode(local: false));

    testWidgets('draws nothing and takes no space', (tester) async {
      await pump(tester, pageWithBanner());

      expect(find.text("You're working locally on this computer"), findsNothing);
      expect(find.text('Create online account'), findsNothing);
      expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
    });

    testWidgets('is not on the log screen', (tester) async {
      await pump(tester, const LoggingView());

      expect(find.text("You're working locally on this computer"), findsNothing);
    });
  });

  testWidgets('without an app mode registered it is simply absent', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop));

    await pump(tester, pageWithBanner());

    expect(find.byType(LocalModeBanner), findsOneWidget);
    expect(find.text("You're working locally on this computer"), findsNothing);
  });
}
