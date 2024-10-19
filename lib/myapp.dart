import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'routing.dart';
import 'services/infra/platform/platform_context.dart';
import 'services/infra/platform/platform_type.dart';
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

    return MaterialApp.router(
      routerConfig: Routing.createRoutes(isDesktop, authenticationService, passwordResetService),
      debugShowCheckedModeBanner: false,
      title: 'Home Management',
      theme: LightTheme.create(),
      darkTheme: DarkTheme.create(),
      themeMode: ThemeMode.system,
    );
  }
}
