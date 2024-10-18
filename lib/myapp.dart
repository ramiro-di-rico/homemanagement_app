import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/account.dart';
import 'services/infra/platform/platform_context.dart';
import 'services/infra/platform/platform_type.dart';
import 'views/accounts/account-detail-desktop.dart';
import 'views/accounts/account-metrics.dart';
import 'views/accounts/account.detail.dart';
import 'views/authentication/2fa_view.dart';
import 'views/authentication/login-desktop.dart';
import 'views/authentication/login.dart';
import 'views/authentication/registration-desktop.dart';
import 'views/authentication/registration.dart';
import 'views/main/home-desktop.dart';
import 'views/main/home.dart';
import 'views/main/logging_view.dart';
import 'views/main/settings.dart';
import 'views/main/settings_desktop.dart';
import 'views/main/transactions_search_desktop_view.dart';

class MyApp extends StatelessWidget {
  final PlatformContext _platformContext;

  MyApp(this._platformContext);

  @override
  Widget build(BuildContext context) {
    _platformContext.setContext(context);
    var platformType = _platformContext.getPlatformType();
    var isDesktop = platformType == PlatformType.Desktop ||
        platformType == PlatformType.Web;

    return MaterialApp.router(
      routerConfig: GoRouter(
          routes: [
            GoRoute(
                path: '/',
                redirect: (context, state) {
                  return HomeScreen.fullPath;
                }),
            GoRoute(
              path: LoginView.fullPath,
              builder: (context, state) =>
                  !isDesktop ? LoginView() : DesktopLoginView(),
            ),
            GoRoute(
              path: RegistrationScreen.fullPath,
              builder: (context, state) =>
                  !isDesktop ? RegistrationScreen() : RegistrationDesktop(),
            ),
            GoRoute(
                path: HomeScreen.fullPath,
                builder: (context, state) =>
                    !isDesktop ? HomeScreen() : HomeDesktop(),
                routes: [
                  GoRoute(
                    path: TransactionsSearchDesktopView.path,
                    builder: (context, state) =>
                        TransactionsSearchDesktopView(),
                  ),
                  GoRoute(
                    path: AccountDetailScreen.path,
                    builder: (context, state) => !isDesktop
                        ? AccountDetailScreen(state.extra as AccountModel)
                        : AccountDetailDesktop(state.extra as AccountModel),
                    routes: [
                      GoRoute(
                        path: AccountMetrics.path,
                        builder: (context, state) =>
                            AccountMetrics(state.extra as AccountModel),
                      ),
                    ]
                  ),
                  GoRoute(
                    path: SettingsScreen.path,
                    builder: (context, state) =>
                        !isDesktop ? SettingsScreen() : SettingsDesktopView(),
                  ),
                  GoRoute(
                    path: LoggingView.path,
                    builder: (context, state) => LoggingView(),
                  ),
                ]),
            GoRoute(
              path: TwoFactorAuthenticationView.fullPath,
              builder: (context, state) => TwoFactorAuthenticationView(),
            )
          ],
          initialLocation: LoginView.fullPath,
          redirect: (context, state) {
            return null;
          }),
      debugShowCheckedModeBanner: false,
      title: 'Home Management',
      theme: ThemeData.light().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
