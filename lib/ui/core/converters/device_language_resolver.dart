import 'dart:ui';

import 'package:home_management_app/l10n/app_localizations.dart';

/// Resolves the language code sent to the backend from the device locale.
///
/// Matches language plus country first (`es_AR` -> `es-AR`), then language only
/// (`it_IT` -> `it`), and falls back to `en`. The `-` format matches what the
/// settings screen stores and what `MyApp` parses.
String resolveDeviceLanguage(
  Locale deviceLocale, {
  List<Locale> supportedLocales = AppLocalizations.supportedLocales,
}) {
  final country = deviceLocale.countryCode;
  if (country != null && country.isNotEmpty) {
    final exact = supportedLocales.any(
      (l) =>
          l.languageCode == deviceLocale.languageCode &&
          l.countryCode == country,
    );
    if (exact) {
      return '${deviceLocale.languageCode}-$country';
    }
  }

  final languageOnly = supportedLocales.any(
    (l) => l.languageCode == deviceLocale.languageCode && l.countryCode == null,
  );
  return languageOnly ? deviceLocale.languageCode : 'en';
}
