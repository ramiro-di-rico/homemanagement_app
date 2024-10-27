import 'package:go_router/go_router.dart';

import 'models/account.dart';
import 'services/security/authentication.service.dart';
import 'services/security/password_reset_service.dart';
import 'views/accounts/account-detail-desktop.dart';
import 'views/accounts/account-metrics.dart';
import 'views/accounts/account.detail.dart';
import 'views/authentication/2fa_view.dart';
import 'views/authentication/login-desktop.dart';
import 'views/authentication/login.dart';
import 'views/authentication/registration-desktop.dart';
import 'views/authentication/registration.dart';
import 'views/authentication/reset_password_view.dart';
import 'views/main/home-desktop.dart';
import 'views/main/home.dart';
import 'views/main/logging_view.dart';
import 'views/main/settings.dart';
import 'views/main/settings_desktop.dart';
import 'views/main/transactions_search_desktop_view.dart';

class Routing{

  static GoRouter createRoutes(bool isDesktop, AuthenticationService authenticationService, PasswordResetService passwordResetService){
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => HomeScreen.fullPath,
        ),
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
                builder: (context, state) => TransactionsSearchDesktopView(),
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
                  ]),
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
        ),
        GoRoute(
          path: ResetPasswordView.fullPath,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final token = state.uri.queryParameters['token'];

            passwordResetService.setResetPasswordQueryParams(
                email.toString(), token.toString());
            return ResetPasswordView();
          },
        )
      ],
      initialLocation: LoginView.fullPath,
      redirect: (context, state) {
        var emailQueryParam = state.uri.queryParameters['email'] ?? '';
        var tokenQueryParam = state.uri.queryParameters['token'] ?? '';
        if (state.matchedLocation == ResetPasswordView.fullPath &&
            emailQueryParam.isNotEmpty &&
            tokenQueryParam.isNotEmpty) {
          return state.uri.path +
              '?email=' +
              emailQueryParam +
              '&token=' +
              tokenQueryParam;
        }

        if (passwordResetService.isResettingPassword()) {
          return ResetPasswordView.fullPath +
              passwordResetService.resetPasswordQueryParams();
        }

        if (!authenticationService.isAuthenticated()){
          return LoginView.fullPath;
        }

        return null;
      },
    );
  }
}