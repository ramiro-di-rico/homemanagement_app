import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/ui/core/converters/device_language_resolver.dart';

void main() {
  group('resolveDeviceLanguage', () {
    test('keeps supported language-only locales', () {
      expect(resolveDeviceLanguage(const Locale('en')), 'en');
      expect(resolveDeviceLanguage(const Locale('es')), 'es');
      expect(resolveDeviceLanguage(const Locale('it')), 'it');
      expect(resolveDeviceLanguage(const Locale('pt')), 'pt');
    });

    test('drops the country when only the language is supported', () {
      expect(resolveDeviceLanguage(const Locale('it', 'IT')), 'it');
      expect(resolveDeviceLanguage(const Locale('pt', 'BR')), 'pt');
      expect(resolveDeviceLanguage(const Locale('es', 'MX')), 'es');
    });

    test('keeps language and country when supported', () {
      expect(resolveDeviceLanguage(const Locale('es', 'AR')), 'es-AR');
    });

    test('falls back to en for unsupported languages', () {
      expect(resolveDeviceLanguage(const Locale('fr', 'FR')), 'en');
    });
  });
}
