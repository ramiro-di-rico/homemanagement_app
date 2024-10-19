import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/services/infra/platform/platform_context.dart';
import 'package:home_management_app/services/repositories/user.repository.dart';
import 'package:local_auth/local_auth.dart';
import '../../models/view-models/user-view-model.dart';
import '../endpoints/identity.service.dart';
import '../infra/cryptography.service.dart';
import '../infra/error_notifier_service.dart';
import '../infra/logger_wrapper.dart';
import '../infra/platform/platform_type.dart';

class AuthenticationService {
  CryptographyService _cryptographyService;
  UserRepository _userRepository;
  late IdentityService _identityService;
  PlatformContext _platformContext;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final NotifierService _notifierService;
  bool _isBiometricEnabled = false;
  late LoggerWrapper? _logger;
  UserModel? user;

  AuthenticationService(this._cryptographyService, this._userRepository, this._platformContext, this._notifierService, LoggerWrapper? logger) {
    _logger = logger;
    _identityService = IdentityService(_logger);
  }

  bool isAuthenticating = false;

  Future<bool> init() async {
    try {
      _logger?.i('Initializing authentication service...');
      this.user = await this._userRepository.load();

      _logger?.i('Checking if can auto authenticate...');
      if (!canAutoAuthenticate()) return false;

      _logger?.i('Checking if is authenticated...');
      if (isAuthenticated()) {
        _logger?.i('User is already authenticated');
        await refreshToken();
        return true;
      }

      if (_platformContext.getPlatformType() != PlatformType.Mobile) {
        return false;
      }

      _logger?.i('Checking if biometric is enabled...');
      _isBiometricEnabled =
          await _localAuth.isDeviceSupported() && await _localAuth.canCheckBiometrics;
      if (_isBiometricEnabled) {
        _logger?.i('Biometric is enabled, authenticating...');
        return await biometricsAuthenticate();
      }

      _logger?.i('Biometrics are not enabled');
      return false;
    } on Exception catch (e) {
      _notifierService.notify('Unable to authenticate');
      return false;
    }
  }

  bool canAutoAuthenticate() {
    return user != null;
  }

  bool isAuthenticated() {
    var currentUtcDate = DateTime.now().toUtc();

    if (user == null) return false;

    return user!.expirationDate.isAfter(currentUtcDate);
  }

  Future<bool> biometricsAuthenticate() async {
    var authOptions =
        AuthenticationOptions(stickyAuth: true, biometricOnly: true);

    _logger?.i('Authenticating using biometrics...');
    var biometricAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: authOptions);

    if (biometricAuthenticated) {
      await refreshToken();
      return true;
    }

    return false;
  }

  Future<bool> autoAuthenticate(){
    return _authenticateImpl(user!.email, user!.password);
  }

  String getUserToken() => user!.token;

  Future<bool> authenticate(UserViewModel userViewModel) async {
    var pass = await _cryptographyService.encryptToAES(userViewModel.password);

    return await _authenticateImpl(userViewModel.email, pass);
  }

  Future<bool> completeTwoFactorAuthentication(String code) async {
    var result = await _identityService.completeTwoFactorAuthentication(user!.username, code);
    if (result != null) {
      user = result;
      _userRepository.store(user!);
      return true;
    }

    return false;
  }

  Future refreshToken() async {
    var user = await _identityService.refreshToken(this.user);
    this.user = user;

    _logger?.i('Authentication succeeded, storing user');
    this._userRepository.store(user!);
  }

  Future<bool> _authenticateImpl(String email, String password) async {
    try {
      isAuthenticating = true;

      _logger?.i('Authenticating...');
      user = isEmailAuthenticationType(email)
          ? await _identityService.internalAuthenticate(email, password)
        : await _identityService.internalAuthenticateV2(email, password);

      if (user == null) {
      _logger?.i('Authentication failed');
      return false;
    }
      _logger?.i('Authentication succeeded, storing user');
      this._userRepository.store(user!);
      return user?.twoFactorRequired == false;
    } on Exception catch (e) {
      _logger?.e(e);
      return false;
    }
    finally {
      isAuthenticating = false;
    }
  }

  Future<bool> register(String email, String password) async {
    var pass = await _cryptographyService.encryptToAES(password);

    var result = await _identityService.register(email, pass);

    return result;
  }

  void logout() {
    this.user = null;
    this._userRepository.clear();
  }

  isEmailAuthenticationType(String email) {
    return email.contains('@');
  }
}
