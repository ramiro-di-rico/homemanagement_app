import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/user.repository.dart';
import 'package:home_management_app/data/services/identity_user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local mode has no server, so any call to it is a failure.
class _NoServer implements IdentityUserService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('reached the server');
}

/// Theme and language in local mode (RF-10): saved on the device, and still there
/// after the app is restarted, which here is a new repository over the same
/// stored preferences.
void main() {
  IdentityUserRepository create() =>
      IdentityUserRepository(_NoServer(), UserRepository());

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('before the preferences are loaded there are only the defaults', () {
    final repository = create();

    expect(repository.themeMode, ThemeMode.system);
    expect(repository.getCurrentLanguage(), '');
  });

  test('a theme and a language chosen in local mode survive a restart, with no server call',
      () async {
    final first = create();
    await first.loadPreferences();
    await first.setThemeMode(ThemeMode.dark);
    await first.setLocalLanguage('es-AR');
    expect(first.themeMode, ThemeMode.dark);
    expect(first.getCurrentLanguage(), 'es-AR');

    final restarted = create();
    expect(restarted.themeMode, ThemeMode.system, reason: 'not read until loaded');
    await restarted.loadPreferences();

    expect(restarted.themeMode, ThemeMode.dark);
    expect(restarted.getCurrentLanguage(), 'es-AR');
  });

  test('choosing a language works even if the preferences were never loaded', () async {
    // This used to do nothing: the preferences were only opened by a sign-in.
    final repository = create();

    await repository.setLocalLanguage('it');
    await repository.setThemeMode(ThemeMode.light);

    expect(repository.getCurrentLanguage(), 'it');
    final restarted = create();
    await restarted.loadPreferences();
    expect(restarted.getCurrentLanguage(), 'it');
    expect(restarted.themeMode, ThemeMode.light);
  });

  test('loading tells the listeners, so the app can apply what was saved', () async {
    SharedPreferences.setMockInitialValues({
      IdentityUserRepository.themeModeKey: ThemeMode.dark.index,
      IdentityUserRepository.languageKey: 'pt',
    });
    final repository = create();
    var notified = 0;
    repository.addListener(() => notified++);

    await repository.loadPreferences();

    expect(notified, 1);
    expect(repository.themeMode, ThemeMode.dark);
    expect(repository.getCurrentLanguage(), 'pt');
  });

  test('a stored theme that is not valid falls back to the system theme', () async {
    SharedPreferences.setMockInitialValues({IdentityUserRepository.themeModeKey: 99});
    final repository = create();

    await repository.loadPreferences();

    expect(repository.themeMode, ThemeMode.system);
  });
}
