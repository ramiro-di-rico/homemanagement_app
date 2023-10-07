import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/repositories/user.repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'endpoints/identity.service.dart';
import 'infra/cryptography.service.dart';
import 'infra/file_logger_output.dart';

class AuthenticationService extends ChangeNotifier {
  CryptographyService cryptographyService;
  UserRepository userRepository;
  IdentityService _identityService = IdentityService();
  final LocalAuthentication auth = LocalAuthentication();
  UserModel? user;
  bool isBiometricEnabled = false;
  final _logger = Logger(
    filter: null,
    printer: PrettyPrinter(),
    output: FileLoggerOutput(),
  );

  AuthenticationService(
      {required this.cryptographyService, required this.userRepository});

  Future init() async {
    _logger.i('Initializing authentication service...');
    this.user = await this.userRepository.load();

    _logger.i('Checking if can auto authenticate...');
    if (!canAutoAuthenticate()) return;

    _logger.i('Checking if is authenticated...');
    if (isAuthenticated()) {
      notifyListeners();
      return;
    }

    _logger.i('Checking if biometric is enabled...');
    isBiometricEnabled =
        await auth.isDeviceSupported() && await auth.canCheckBiometrics;
    if (isBiometricEnabled) {
      await biometricsAuthenticate();
    }
  }

  bool canAutoAuthenticate() {
    return user != null;
  }

  bool isAuthenticated() {
    var currentUtcDate = DateTime.now().toUtc();
    return user!.expirationDate.isAfter(currentUtcDate);
  }

  Future biometricsAuthenticate() async {
    var authOptions =
        AuthenticationOptions(stickyAuth: true, biometricOnly: true);

    _logger.i('Authenticating using biometrics...');
    var biometricAuthenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: authOptions);

    if (biometricAuthenticated) {
      await this.autoAuthenticate();
    }
  }

  Future autoAuthenticate() async => isEmailAuthenticationType(this.user!.email)
      ? await _identityService.internalAuthenticate(this.user!.email, this.user!.password)
      : await _identityService.internalAuthenticateV2(this.user!.email, this.user!.password);

  String getUserToken() => user!.token;

  Future<bool> authenticate(String email, String password) async {
    try {
      _logger.i('Authenticating...');
      var pass = await cryptographyService.encryptToAES(password);

      var user = isEmailAuthenticationType(email)
          ? await _identityService.internalAuthenticate(email, password)
          : await _identityService.internalAuthenticateV2(email, pass);

      this.userRepository.store(user!);
      this.notifyListeners();
      return true;
    } on Exception catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    var pass = await cryptographyService.encryptToAES(password);

    var result = await _identityService.register(email, pass);

    return result;
  }

  void logout() {
    this.user = null;
    this.userRepository.clear();
  }

  isEmailAuthenticationType(String email) {
    return email.contains('@');
  }
}
