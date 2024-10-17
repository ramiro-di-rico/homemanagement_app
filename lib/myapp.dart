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
    var isDesktop = platformType == PlatformType.Desktop || platformType == PlatformType.Web;

    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) {
              return HomeScreen.id;
            }
          ),
          GoRoute(
            path: LoginView.id,
            builder: (context, state) => !isDesktop ? LoginView() : DesktopLoginView(),
          ),
          GoRoute(
            path: RegistrationScreen.id,
            builder: (context, state) => !isDesktop ? RegistrationScreen() : RegistrationDesktop(),
          ),
          GoRoute(
            path: HomeScreen.id,
            builder: (context, state) => !isDesktop ? HomeScreen() : HomeDesktop(),
            routes: [
              GoRoute(
                path: TransactionsSearchDesktopView.id,
                builder: (context, state) => TransactionsSearchDesktopView(),
              ),
              GoRoute(
                path: AccountDetailScreen.id,
                builder: (context, state) => !isDesktop ? AccountDetailScreen(state.extra as AccountModel) : AccountDetailDesktop(state.extra as AccountModel),
              ),
            ]
          ),
          GoRoute(
            path: AccountMetrics.id,
            builder: (context, state) => AccountMetrics(state.extra as AccountModel),
          ),
          GoRoute(
            path: LoggingView.id,
            builder: (context, state) => LoggingView(),
          ),
          GoRoute(
            path: TwoFactorAuthenticationView.id,
            builder: (context, state) => TwoFactorAuthenticationView(),
          ),
          GoRoute(
            path: SettingsScreen.id,
            builder: (context, state) => !isDesktop ? SettingsScreen() : SettingsDesktopView(),
          ),
        ],
        initialLocation: LoginView.id,
        redirect: (context, state) {
          return null;
        }
      ),
      debugShowCheckedModeBanner: false,
      title: 'Home Management',
      theme: ThemeData.light().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
            trackColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          )),
      darkTheme: ThemeData.dark().copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
          radioTheme: RadioThemeData(
            fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return null;
              }
              if (states.contains(MaterialState.selected)) {
                return Colors.pinkAccent;
              }
              return null;
            }),
          ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
