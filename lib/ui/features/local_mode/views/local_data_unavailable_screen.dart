import 'package:flutter/material.dart';
import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

/// Shown instead of the app when the local data exists but can't be opened
/// (locked keyring, lost key, unreadable file).
///
/// It only offers Retry. The data is never deleted or reset from here: a locked
/// keyring is usually temporary, and the file is the user's only copy.
class LocalDataUnavailableScreen extends StatefulWidget {
  final AppModeService appModeService;

  const LocalDataUnavailableScreen({super.key, required this.appModeService});

  @override
  State<LocalDataUnavailableScreen> createState() =>
      _LocalDataUnavailableScreenState();
}

class _LocalDataUnavailableScreenState
    extends State<LocalDataUnavailableScreen> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.appModeService.init();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reason = widget.appModeService.startupError?.reason;
    final detail = reason == LocalDataUnavailableReason.keyringUnavailable
        ? l10n.localModeKeyringUnavailable
        : l10n.localDataCannotBeOpenedDetail;

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
                  Text(detail,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _retrying ? null : _retry,
                    icon: _retrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
