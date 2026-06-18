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

  void _loadThemeMode() {
    final themeIndex = _userRepository.preferences?.getInt(themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
  }

  Future setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _userRepository.preferences?.setInt(themeModeKey, mode.index);
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
