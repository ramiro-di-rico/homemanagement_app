import 'package:flutter/material.dart';
import 'package:home_management_app/ui/features/authentication/view_models/my_user_view_model.dart';
import 'package:home_management_app/data/services/identity_user_service.dart';
import 'user.repository.dart';

class IdentityUserRepository extends ChangeNotifier {
  static const String languageKey = 'Language';
  static const String useMainAccountsKey = 'useMainAccounts';
  static const String themeModeKey = 'themeMode';

  final IdentityUserService _identityUserApi;
  final UserRepository _userRepository;
  MyUserViewModel? _currentUser;
  ThemeMode _themeMode = ThemeMode.system;

  IdentityUserRepository(this._identityUserApi, this._userRepository) {
    _loadThemeMode();
  }

  MyUserViewModel? get currentUser => _currentUser;
  ThemeMode get themeMode => _themeMode;

  /// Reads the saved theme and language, in every mode. Without it they are only
  /// available after a sign-in, so local mode would start with the defaults and
  /// forget what the user chose.
  Future<void> loadPreferences() async {
    await _userRepository.loadPreferences();
    _loadThemeMode();
    notifyListeners();
  }

  void _loadThemeMode() {
    final themeIndex = _userRepository.preferences?.getInt(themeModeKey) ?? ThemeMode.system.index;
    _themeMode = themeIndex >= 0 && themeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;
  }

  Future setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final preferences = await _userRepository.loadPreferences();
    await preferences.setInt(themeModeKey, mode.index);
    notifyListeners();
  }

  Future<MyUserViewModel?> getUser() async {
    _currentUser = _currentUser ?? await _identityUserApi.getUser();
    notifyListeners();
    return _currentUser;
  }

  String getCurrentLanguage() {
    if (_currentUser?.language != null && _currentUser!.language!.isNotEmpty) {
      return _currentUser!.language!;
    }
    return _userRepository.preferences?.getString(languageKey) ?? '';
  }

  bool getUseMainAccounts() {
    return _userRepository.preferences?.getBool(useMainAccountsKey) ?? false;
  }

  Future setUseMainAccounts(bool value) async {
    await _userRepository.preferences?.setBool(useMainAccountsKey, value);
    notifyListeners();
  }

  /// Saves the language on this device only, without calling the server.
  /// Used in local mode, where there is no signed-in user.
  Future setLocalLanguage(String language) async {
    final preferences = await _userRepository.loadPreferences();
    await preferences.setString(languageKey, language);
    notifyListeners();
  }

  Future<MyUserViewModel> updateLanguage(
    String language,
    String timeZone,
  ) async {
    final updatedUser = await _identityUserApi.updateLanguage(
      language,
      timeZone,
    );
    _currentUser = updatedUser;
    // Also update local preference for fallback
    await _userRepository.preferences?.setString(languageKey, language);
    notifyListeners();
    return updatedUser;
  }
}
