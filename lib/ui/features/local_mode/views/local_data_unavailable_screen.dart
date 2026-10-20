import 'package:flutter/material.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

import 'local_data_unavailable_message.dart';

/// Shown instead of the app when the local data exists but can't be opened
/// (locked keyring, lost key, unreadable or missing file).
///
/// The data is never deleted or reset from here: the file is the user's only
/// copy. The user can retry when that can help, and can always leave to the online
/// app, so a broken local file never makes the whole app unusable. Starting again
/// with empty data is offered only when the file is missing, and only as an
/// explicit choice.
class LocalDataUnavailableScreen extends StatefulWidget {
  final AppModeService appModeService;

  const LocalDataUnavailableScreen({super.key, required this.appModeService});

  @override
  State<LocalDataUnavailableScreen> createState() =>
      _LocalDataUnavailableScreenState();
}

class _LocalDataUnavailableScreenState
    extends State<LocalDataUnavailableScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on LocalDataUnavailableException {
      // The service keeps the reason; the screen rebuilds with it.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retry() async {
    await _run(widget.appModeService.init);
    if (!mounted || widget.appModeService.startupError == null) return;
    // Say that it ran, so a retry that fails the same way isn't mistaken for a dead button.
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.localDataRetryFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reason = widget.appModeService.startupError?.reason ??
        LocalDataUnavailableReason.unreadable;
    final canRetry = localDataRetryCanHelp(reason);
    final canStartEmpty = reason == LocalDataUnavailableReason.fileMissing;

    final retry = FilledButton.icon(
      autofocus: true,
      onPressed: _busy ? null : _retry,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.refresh),
      label: Text(l10n.retry),
    );
    final online = TextButton(
      autofocus: !canRetry,
      onPressed: _busy ? null : () => _run(widget.appModeService.leaveLocalMode),
      child: Text(l10n.useOnlineAccountInstead),
    );
    final startEmpty = OutlinedButton(
      onPressed: _busy ? null : () => _run(widget.appModeService.enterLocalMode),
      child: Text(l10n.startWithEmptyData),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,
                      size: 56, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.localDataCannotBeOpened,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(localDataUnavailableMessage(l10n, reason),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  if (canRetry) retry,
                  if (canStartEmpty) ...[const SizedBox(height: 12), startEmpty],
                  const SizedBox(height: 12),
                  online,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
