import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/accounts/views/account-list-desktop.dart';
import 'package:home_management_app/ui/features/authentication/views/login.dart';
import 'package:home_management_app/ui/features/authentication/views/registration.dart';
import 'package:home_management_app/ui/features/home/views/shared/account-sheet-dektop.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_mode_banner.dart';
import 'package:home_management_app/ui/features/settings/views/settings.dart';

/// The desktop home in local mode. It replaces `HomeDesktop` rather than
/// branching inside it, so the online home stays untouched.
///
/// Only what works without a server is here: no dashboard, reminders, tags,
/// budget or user profile. Local mode makes no network calls (FR-004).
class LocalHomeDesktop extends StatefulWidget {
  const LocalHomeDesktop({super.key});

  @override
  State<LocalHomeDesktop> createState() => _LocalHomeDesktopState();
}

class _LocalHomeDesktopState extends State<LocalHomeDesktop> {
  final AppModeService _appMode = GetIt.I<AppModeService>();
  final AccountRepository _accounts = GetIt.I<AccountRepository>();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _accounts.load().whenComplete(() {
      if (mounted) setState(() => _loaded = true);
    });
    GetIt.I<CurrencyRepository>().load();
    GetIt.I<CategoryRepository>().load();
  }

  /// "Sign in to an existing account" leaves local mode, but keeps the local data
  /// on this computer. It never moves it to that account, so the user is told.
  Future<void> _signInToExistingAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signInExistingAccount),
        content: Text(l10n.signInExistingAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signIn),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _appMode.leaveLocalMode();
    if (!mounted) return;
    context.go(LoginView.fullPath);
  }

  void _openNewAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxHeight: 500, maxWidth: 1200),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) => SizedBox(
        height: 100,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(seconds: 1),
          child: AccountSheetDesktop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([_appMode, _accounts]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          bottom: const LocalModeBanner(),
          actions: [
            TextButton.icon(
              onPressed: () => context.go(RegistrationScreen.fullPath),
              icon: const Icon(Icons.cloud_outlined),
              label: Text(l10n.createOnlineAccount),
            ),
            // Not while an import is pending: the move must be finished first.
            if (!_appMode.isImportPending)
              TextButton.icon(
                onPressed: _signInToExistingAccount,
                icon: const Icon(Icons.login),
                label: Text(l10n.signInExistingAccount),
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.settings,
              onPressed: () => context.push(SettingsScreen.fullPath),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(16),
                // Hidden accounts count: only a really empty start shows the welcome.
                child: _loaded && _accounts.getAllAccounts().isEmpty
                    ? _EmptyState(onCreate: _openNewAccountSheet)
                    : AccountListDesktopView(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What a first-time local user sees: where the data lives, and one obvious step.
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(l10n.localModeEmptyDescription,
            textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        FilledButton.icon(
          autofocus: true,
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: Text(l10n.createFirstAccount),
        ),
      ],
    );
  }
}
