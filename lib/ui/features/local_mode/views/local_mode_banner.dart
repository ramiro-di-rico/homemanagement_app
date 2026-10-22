import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_import_screen.dart';

/// Where "finish moving your local data" leads: the import screen when the user is
/// signed in, and the login otherwise (the account already exists, so registering
/// again would only say the email is taken). The router lets the login through
/// while an import is pending.
void openImportResume(BuildContext context) {
  final authentication = GetIt.I<AuthenticationService>();
  context.go(authentication.isAuthenticated()
      ? LocalImportScreen.fullPath
      : LoginView.pathFor(email: GetIt.I<AppModeService>().importTargetEmail));
}

/// A persistent strip saying the user is working locally, with the way to create
/// an online account (FR-017).
///
/// It is meant for `AppBar.bottom`, so it stays visible while the page scrolls and
/// needs no change to the screen's body. Online it takes no space and draws
/// nothing, so it can be placed on screens that serve both modes.
class LocalModeBanner extends StatelessWidget implements PreferredSizeWidget {
  const LocalModeBanner({super.key});

  static const double _height = 48;

  bool get _isLocal =>
      GetIt.I.isRegistered<AppModeService>() &&
      GetIt.I<AppModeService>().isLocal;

  @override
  Size get preferredSize => _isLocal ? const Size.fromHeight(_height) : Size.zero;

  @override
  Widget build(BuildContext context) {
    if (!_isLocal) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.secondaryContainer,
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.laptop, size: 20, color: colors.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.localModeBanner,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onSecondaryContainer),
                ),
              ),
              // Once the move has started the account exists: finishing it replaces
              // creating one.
              ListenableBuilder(
                listenable: GetIt.I<AppModeService>(),
                builder: (context, _) => TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: colors.onSecondaryContainer),
                  onPressed: GetIt.I<AppModeService>().isImportPending
                      ? () => openImportResume(context)
                      : () => context.go(RegistrationScreen.fullPath),
                  child: Text(GetIt.I<AppModeService>().isImportPending
                      ? l10n.importResume
                      : l10n.createOnlineAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
