import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/local/local_database.dart';
import 'package:home_management_app/data/models/import_progress.dart';
import 'package:home_management_app/data/repositories/local_import.repository.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/data/services/sources/import_currency_missing_exception.dart';
import 'package:home_management_app/data/services/sources/import_server_not_ready_exception.dart';
import 'package:home_management_app/data/services/sources/import_wrong_user_exception.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';

/// Moves the local data into the account the user just created, and shows how it
/// goes (FR-021 to FR-023).
///
/// It starts the move by itself when it opens. After an app restart in the middle
/// of a move it resumes it. After a failure it waits for the user to retry, and the
/// app stays local with its data intact.
class LocalImportScreen extends StatefulWidget {
  /// A top-level route, not a child of `/home_screen`. A child keeps the home page
  /// underneath it, and that page is only built at the first rebuild: exactly when
  /// the move ends and the mode flips. It was then built as the home of the wrong
  /// mode, with the database already closed (or, online, loading everything at once).
  static const String fullPath = '/local_import';

  const LocalImportScreen({super.key});

  @override
  State<LocalImportScreen> createState() => _LocalImportScreenState();
}

class _LocalImportScreenState extends State<LocalImportScreen> {
  final LocalImportRepository _import = GetIt.I<LocalImportRepository>();
  final AppModeService _appMode = GetIt.I<AppModeService>();

  /// The steps worth showing. Preflight is instant, and restoring names is part
  /// of finishing the transactions. Waiting for the server only takes time right
  /// after registering, and then the user needs to know why nothing moves.
  static const List<ImportStep> _shownSteps = [
    ImportStep.serverSetup,
    ImportStep.categories,
    ImportStep.accounts,
    ImportStep.transactions,
    ImportStep.verifying,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  void _begin() {
    // Online again means the move already finished: only the summary is left.
    if (!mounted || !_appMode.isLocal || _import.isRunning) return;
    switch (_import.status) {
      case ImportStatus.notStarted || ImportStatus.registered:
        _import.start();
      case ImportStatus.inProgress || ImportStatus.completed:
        // `completed` while still local means archiving failed: finish it.
        _import.resume();
      case ImportStatus.failed:
        break;
    }
  }

  String _errorText(AppLocalizations l10n, Object? error) {
    if (error is ImportCurrencyMissingException) {
      return l10n.importCurrencyMissing(error.codes.join(', '));
    }
    if (error is ImportServerNotReadyException) {
      return l10n.importServerNotReady;
    }
    if (error is ImportWrongUserException) {
      return l10n.importWrongUser(error.expectedEmail);
    }
    return l10n.importFailed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListenableBuilder(
              listenable: Listenable.merge([_import, _appMode]),
              builder: (context, _) => _content(context, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n) {
    final finished =
        _import.status == ImportStatus.completed && !_appMode.isLocal;
    final failed = _import.status == ImportStatus.failed && !_import.isRunning;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      children: [
        if (!finished && !failed) const LinearProgressIndicator(),
        const SizedBox(height: 16),
        for (final step in _shownSteps) _stepRow(context, l10n, step, finished, failed),
        const SizedBox(height: 24),
        if (finished) ...[
          Semantics(
            liveRegion: true,
            child: Text(l10n.importDone, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final mismatch in _import.mismatches)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: colors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.importBalanceMismatch(
                      mismatch.accountName,
                      mismatch.localBalance.toStringAsFixed(2),
                      mismatch.serverBalance.toStringAsFixed(2),
                    )),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              autofocus: true,
              onPressed: () => context.go(HomeScreen.fullPath),
              child: Text(l10n.continueButton),
            ),
          ),
        ],
        if (failed) ...[
          Semantics(
            liveRegion: true,
            child: Text(_errorText(l10n, _import.error),
                style: TextStyle(color: colors.error)),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              autofocus: true,
              onPressed: _import.resume,
              child: Text(l10n.retry),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stepRow(BuildContext context, AppLocalizations l10n, ImportStep step,
      bool finished, bool failed) {
    final colors = Theme.of(context).colorScheme;
    final current = _import.step;
    final done = finished || (current != null && current.index > step.index);
    final active = !done && current == step;

    final Widget icon;
    if (done) {
      icon = Icon(Icons.check_circle, color: colors.primary);
    } else if (active && failed) {
      icon = Icon(Icons.error, color: colors.error);
    } else if (active) {
      icon = const SizedBox(
          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    } else {
      icon = Icon(Icons.radio_button_unchecked, color: colors.outline);
    }

    final (progressDone, progressTotal) = _import.progress;
    final label = switch (step) {
      ImportStep.serverSetup => l10n.importWaitingForServer,
      ImportStep.categories => l10n.importProgressCategories,
      ImportStep.accounts => l10n.importProgressAccounts,
      ImportStep.transactions => l10n.importProgressTransactions,
      _ => l10n.importVerifying,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 24, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (active && progressTotal > 0) Text('$progressDone / $progressTotal'),
        ],
      ),
    );
  }
}
