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
import 'views/invites/invite_management_screen.dart';
import 'views/invites/public_invite_screen.dart';
import 'views/main/budget_desktop_view.dart';
import 'views/main/home-desktop.dart';
import 'views/main/home.dart';
import 'views/main/logging_view.dart';
import 'views/main/settings.dart';
import 'views/main/settings_desktop.dart';
import 'views/main/statistics_view.dart';
import 'views/main/transactions_search_desktop_view.dart';
import 'views/main/transactions_search_statistics_view.dart';
import 'views/screens/bulk_transactions_screen.dart';

class Routing{

  static GoRouter createRoutes(bool isDesktop, AuthenticationService authenticationService, PasswordResetService passwordResetService){
    return GoRouter(
      routes: [
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
          path: PublicInviteScreen.fullPath,
          builder: (context, state) => PublicInviteScreen(
            token: state.pathParameters['token'] ?? '',
          ),
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
                path: TransactionsSearchStatisticsView.path,
                builder: (context, state) =>
                    const TransactionsSearchStatisticsView(),
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
              GoRoute(
                path: BudgetDesktopView.path,
                builder: (context, state) => BudgetDesktopView(),
              ),
              GoRoute(
                path: StatisticsView.path,
                builder: (context, state) => const StatisticsView(),
              ),
              GoRoute(
                path: BulkTransactionsScreen.path,
                builder: (context, state) => const BulkTransactionsScreen(),
              ),
              GoRoute(
                path: InviteManagementScreen.path,
                builder: (context, state) => const InviteManagementScreen(),
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
        var viewQueryParam = state.uri.queryParameters['view'] ?? '';

        if (passwordResetService.isResettingPassword()) {
          return ResetPasswordView.fullPath +
              passwordResetService.resetPasswordQueryParams();
        }

        if (viewQueryParam == 'reset_password') {
          passwordResetService.setResetPasswordQueryParams(
              emailQueryParam.toString(), tokenQueryParam.toString());
          return ResetPasswordView.fullPath + passwordResetService.resetPasswordQueryParams();
        }

        final isPublicInviteRoute = state.matchedLocation.startsWith('/public/invites/');
        final isRegistrationRoute = state.matchedLocation == RegistrationScreen.fullPath;
        final isLoginRoute = state.matchedLocation == LoginView.fullPath;

        if (isPublicInviteRoute || isRegistrationRoute || isLoginRoute) {
          return null;
        }

        if (!authenticationService.isAuthenticated()){
          return LoginView.fullPath;
        }

        return null;
      },
    );
  }
}
