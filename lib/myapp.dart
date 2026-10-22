import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'routing.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_type.dart';
import 'package:home_management_app/data/services/deep_link_service.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/password_reset_service.dart';
import 'package:home_management_app/ui/core/themes/dark_theme.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_data_unavailable_screen.dart';
import 'package:home_management_app/ui/core/themes/light_theme.dart';

class MyApp extends StatelessWidget {
  final PlatformContext _platformContext;

  MyApp(this._platformContext);

  @override
  Widget build(BuildContext context) {
    _platformContext.setContext(context);
    var platformType = _platformContext.getPlatformType();
    var isDesktop = platformType == PlatformType.Desktop ||
        platformType == PlatformType.Web;

    var authenticationService = GetIt.I.get<AuthenticationService>();
    var passwordResetService = GetIt.I.get<PasswordResetService>();
    var deepLinkService = GetIt.I.get<DeepLinkService>();
    var identityUserRepository = GetIt.I.get<IdentityUserRepository>();
    var appModeService = GetIt.I.get<AppModeService>();
    final router = Routing.createRoutes(isDesktop, authenticationService, passwordResetService, appModeService);
    deepLinkService.attachRouter(router);

    return ListenableBuilder(
      listenable: Listenable.merge([identityUserRepository, appModeService]),
      builder: (context, _) {
        var languageCode = identityUserRepository.getCurrentLanguage();
        Locale? locale;
        if (languageCode.isNotEmpty) {
          if (languageCode.contains('-')) {
            var parts = languageCode.split('-');
            locale = Locale(parts[0], parts[1].toUpperCase());
          } else {
            locale = Locale(languageCode);
          }
        }

        // The local data couldn't be opened: nothing else may run until it can.
        if (appModeService.startupError != null) {
          return MaterialApp(
            key: ValueKey(locale?.toString() ?? 'default'),
            home: LocalDataUnavailableScreen(appModeService: appModeService),
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            theme: LightTheme.create(),
            darkTheme: DarkTheme.create(),
            themeMode: identityUserRepository.themeMode,
          );
        }

        return MaterialApp.router(
          key: ValueKey(locale?.toString() ?? 'default'),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: LightTheme.create(),
          darkTheme: DarkTheme.create(),
          themeMode: identityUserRepository.themeMode,
        );
      },
    );
  }
}
