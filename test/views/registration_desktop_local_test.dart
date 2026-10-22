import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/identity.service.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/domain/models/user.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/authentication/view_models/user-view-model.dart';
import 'package:home_management_app/ui/features/authentication/views/2fa_view.dart';
import 'package:home_management_app/ui/features/authentication/views/registration-desktop.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_platform.dart';

/// Records what the app mode says at the moment each call is made, because the
/// order is the point: the account must be remembered before signing in (SP-01).
class _Auth implements AuthenticationService {
  final AppModeService appMode;
  RegistrationResult registerResult = RegistrationResult.success;
  final List<String> calls = [];
  ImportStatus? statusWhenAuthenticating;
  String? emailWhenAuthenticating;

  _Auth(this.appMode);

  @override
  UserModel? user;

  @override
  Future<bool> init() async => false;

  @override
  bool isAuthenticated() => false;

  @override
  Future<RegistrationResult> register(String email, String password,
      [String language = 'en']) async {
    calls.add('register');
    return registerResult;
  }

  @override
  Future<bool> authenticate(UserViewModel userViewModel) async {
    calls.add('authenticate');
    statusWhenAuthenticating = appMode.importStatus;
    emailWhenAuthenticating = appMode.importTargetEmail;
    // A sign-in that asks for the two-factor code, which is where it can stall.
    user = UserModel(userViewModel.email, '', '', '', '', DateTime(2030), true);
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppModeService appMode;
  late _Auth auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    appMode = AppModeService(FakePlatform(PlatformType.Desktop),
        openDatabase: (_, {required mustExist}) async =>
            LocalDatabase(NativeDatabase.memory()));
    await appMode.init();
    await appMode.enterLocalMode();
    auth = _Auth(appMode);
    GetIt.I
      ..registerSingleton<AppModeService>(appMode)
      ..registerSingleton<AuthenticationService>(auth)
      ..registerSingleton<NotifierService>(NotifierService());
  });

  tearDown(() async {
    await appMode.database?.close();
    await GetIt.I.reset();
  });

  Future<void> signUp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: RegistrationScreen.fullPath,
      routes: [
        GoRoute(
            path: RegistrationScreen.fullPath,
            builder: (_, _) => const RegistrationDesktop()),
        GoRoute(
            path: TwoFactorAuthenticationView.fullPath,
            builder: (_, _) => const Text('TWO FACTOR SCREEN')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'new@user.com');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'Str0ng-Passw0rd');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
  }

  testWidgets('remembers the account before it signs in, so a stalled sign-in can\'t burn the email',
      (tester) async {
    await signUp(tester);

    expect(auth.calls, ['register', 'authenticate']);
    expect(auth.statusWhenAuthenticating, ImportStatus.registered);
    expect(auth.emailWhenAuthenticating, 'new@user.com');
    expect(find.text('TWO FACTOR SCREEN'), findsOneWidget);
    // And it is still remembered now that the sign-in has stopped halfway.
    expect(appMode.importStatus, ImportStatus.registered);
    expect(appMode.isImportPending, isTrue);
  });

  testWidgets('an email that is already taken records nothing and stays on the screen',
      (tester) async {
    auth.registerResult = RegistrationResult.emailTaken;

    await signUp(tester);

    expect(auth.calls, ['register']);
    expect(appMode.importStatus, ImportStatus.notStarted);
    expect(appMode.isImportPending, isFalse);
    expect(find.text('This email is already registered. Use a different email.'),
        findsOneWidget);
  });

  testWidgets('a failed registration records nothing', (tester) async {
    auth.registerResult = RegistrationResult.failed;

    await signUp(tester);

    expect(auth.calls, ['register']);
    expect(appMode.importStatus, ImportStatus.notStarted);
  });
}
