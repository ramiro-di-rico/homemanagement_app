import 'package:flutter/cupertino.dart';
import 'package:home_management_app/l10n/app_localizations.dart';
import 'package:home_management_app/l10n/app_localizations_en.dart';

/// Builds a message in the language the user sees. Repositories have no
/// `BuildContext`, so the view that shows the message supplies the localizations.
typedef LocalizedMessage = String Function(AppLocalizations l10n);

class NotifierService extends ChangeNotifier {
  String? _message;
  LocalizedMessage? _localizedMessage;
  bool? _isError;
  String? get errorMessage => _message;

  bool get hasError => _isError ?? false;

  void notify(String message, {bool isError = false}) {
    // A newer plain message replaces a localized one that nobody has shown yet.
    _localizedMessage = null;
    _message = message;
    _isError = isError;
    notifyListeners();
  }

  /// A local write failed and nothing was saved.
  void notifyChangeNotSaved() =>
      notifyLocalized((l10n) => l10n.changeNotSaved, isError: true);

  void notifyLocalized(LocalizedMessage message, {bool isError = false}) {
    _localizedMessage = message;
    _message = null;
    _isError = isError;
    notifyListeners();
  }

  /// Pass [l10n] so a localized message is shown in the user's language. Without
  /// it, English is used.
  String? getMessage({AppLocalizations? l10n}) {
    final localized = _localizedMessage;
    if (localized != null) {
      _localizedMessage = null;
      return localized(l10n ?? AppLocalizationsEn());
    }
    if (_message == null) return null;
    var message = _message!;
    _message = null;
    return message;
  }
}