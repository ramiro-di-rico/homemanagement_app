import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/password_reset_service.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/main.dart';
import 'package:home_management_app/routing.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:home_management_app/ui/features/authentication/views/reset_password_view.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

/// Exercises the `redirect` of `Routing.createRoutes` without building any screen:
/// the router's own parser resolves each path, running the redirect, and the
/// resulting location is read back. No route builder runs.
void main() {
  late List<LocalDatabase> opened;
  late AppModeService appMode;
  late PasswordResetService passwordReset;
  late AuthenticationService authentication;

  GoRouter createRouter() => Routing.createRoutes(
      true, authentication, passwordReset, appMode);

  /// Where [path] ends up once the redirect has run.
  Future<String> resolve(WidgetTester tester, GoRouter router, String path) async {
    await tester.pumpWidget(const SizedBox());
    final matches = await router.routeInformationParser
        .parseRouteInformationWithDependencies(
            RouteInformation(uri: Uri.parse(path)),
            tester.element(find.byType(SizedBox)));
    return matches.uri.toString();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    opened = [];
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_) async {
      final db = LocalDatabase(NativeDatabase.memory());
      opened.add(db);
      return db;
    });
    await appMode.init();
    registerDependencies(PlatformStrategy.createPlatform(), appModeService: appMode);
    authentication = GetIt.I<AuthenticationService>();
    passwordReset = GetIt.I<PasswordResetService>();
  });

  tearDown(() async {
    for (final db in opened) {
      await db.close();
    }
    await GetIt.I.reset();
  });

  group('local mode, not signed in', () {
    setUp(() async {
      await appMode.enterLocalMode();
      expect(authentication.isAuthenticated(), isFalse);
    });

    testWidgets('the login screen goes to the home', (tester) async {
      expect(await resolve(tester, createRouter(), LoginView.fullPath),
          HomeScreen.fullPath);
    });

    testWidgets('the home is allowed without authentication', (tester) async {
      expect(await resolve(tester, createRouter(), HomeScreen.fullPath),
          HomeScreen.fullPath);
    });

    testWidgets('a public invite link goes to the home', (tester) async {
      expect(await resolve(tester, createRouter(), '/public/invites/abc'),
          HomeScreen.fullPath);
    });

    testWidgets('a password-reset link goes to the home and is not recorded',
        (tester) async {
      final result = await resolve(tester, createRouter(),
          '${LoginView.fullPath}?view=reset_password&email=a%40b.c&token=xyz');

      expect(result, HomeScreen.fullPath);
      expect(passwordReset.isResettingPassword(), isFalse);
    });

    testWidgets('registration can still be reached', (tester) async {
      expect(await resolve(tester, createRouter(), RegistrationScreen.fullPath),
          RegistrationScreen.fullPath);
    });
  });

  group('online mode', () {
    testWidgets('an unauthenticated visitor is sent to the login', (tester) async {
      expect(await resolve(tester, createRouter(), HomeScreen.fullPath),
          LoginView.fullPath);
    });

    testWidgets('a public invite link is still reachable', (tester) async {
      expect(await resolve(tester, createRouter(), '/public/invites/abc'),
          '/public/invites/abc');
    });

    testWidgets('a password-reset link still opens the reset screen',
        (tester) async {
      final result = await resolve(tester, createRouter(),
          '${LoginView.fullPath}?view=reset_password&email=a%40b.c&token=xyz');

      expect(result, startsWith(ResetPasswordView.fullPath));
      expect(passwordReset.isResettingPassword(), isTrue);
    });
  });
}
