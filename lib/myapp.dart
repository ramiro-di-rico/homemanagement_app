import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'routing.dart';
import 'services/infra/platform/platform_context.dart';
import 'services/infra/platform/platform_type.dart';
import 'services/deep_link_service.dart';
import 'services/repositories/preferences.repository.dart';
import 'services/security/authentication.service.dart';
import 'services/security/password_reset_service.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';

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
    var preferencesRepository = GetIt.I.get<PreferencesRepository>();
    final router = Routing.createRoutes(isDesktop, authenticationService, passwordResetService);
    deepLinkService.attachRouter(router);

    return ListenableBuilder(
      listenable: preferencesRepository,
      builder: (context, _) {
        var languageCode = preferencesRepository.getCurrentLanguage();
        Locale? locale;
        if (languageCode.isNotEmpty) {
          if (languageCode.contains('-')) {
            var parts = languageCode.split('-');
            locale = Locale(parts[0], parts[1]);
          } else {
            locale = Locale(languageCode);
          }
        }

        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          theme: LightTheme.create(),
          darkTheme: DarkTheme.create(),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
