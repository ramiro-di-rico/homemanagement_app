import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management_app/data/services/app_mode.service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/ui/features/home/views/home.dart';
import 'package:home_management_app/ui/features/local_mode/views/local_import_screen.dart';

/// Where a sign-in ends up, for a registration and for a login alike. From local mode the new account takes the local data
/// along (FR-018); with nothing but the seeds there is nothing to move, so the
/// switch is immediate. Shared by every path that can finish a registration
/// (direct sign-in and two-factor).
Future<void> goAfterSignIn(BuildContext context) async {
  final appMode = GetIt.I.isRegistered<AppModeService>()
      ? GetIt.I<AppModeService>()
      : null;
  final database = appMode?.database;
  if (appMode == null || !appMode.isLocal || database == null) {
    context.go(HomeScreen.fullPath);
    return;
  }

  // A move that already started always continues, whatever the data looks like.
  final hasLocalData =
      appMode.isImportPending || await database.hasUserData();
  if (!context.mounted) return;
  if (hasLocalData) {
    context.go(LocalImportScreen.fullPath);
    return;
  }

  try {
    await appMode.completeImport();
  } catch (error, stackTrace) {
    // The account exists and the local data is untouched, so stay put.
    developer.log('Could not switch to the new account',
        name: 'post-sign-in', error: error, stackTrace: stackTrace);
    if (!context.mounted) return;
    await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              content: Text(AppLocalizations.of(dialogContext)!.localSwitchFailed),
              actions: [
                TextButton(
                  child: Text('ok'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                )
              ],
            ));
    return;
  }
  if (!context.mounted) return;
  context.go(HomeScreen.fullPath);
}
