import 'package:home_management_app/data/local/local_database_opener.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

/// What to tell the user for each reason the local data can't be opened. Each
/// message says whether the data is safe, and none suggests an action that can't help.
String localDataUnavailableMessage(
    AppLocalizations l10n, LocalDataUnavailableReason reason) {
  switch (reason) {
    case LocalDataUnavailableReason.keyringUnavailable:
      return l10n.localModeKeyringUnavailable;
    case LocalDataUnavailableReason.keyMissing:
      return l10n.localDataKeyMissing;
    case LocalDataUnavailableReason.fileMissing:
      return l10n.localDataFileMissing;
    case LocalDataUnavailableReason.notEncrypted:
    case LocalDataUnavailableReason.unreadable:
      return l10n.localDataUnreadable;
  }
}

/// Whether trying again can change the outcome. A lost key can never come back.
bool localDataRetryCanHelp(LocalDataUnavailableReason reason) =>
    reason != LocalDataUnavailableReason.keyMissing &&
    reason != LocalDataUnavailableReason.notEncrypted;
