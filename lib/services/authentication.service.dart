import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/repositories/user.repository.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'cryptography.service.dart';
import 'infra/file_logger_output.dart';

class AuthenticationService extends ChangeNotifier {
  CryptographyService cryptographyService;
  UserRepository userRepository;
  final LocalAuthentication auth = LocalAuthentication();
  String url = 'ramiro-di-rico.dev';
  String authenticateApi = 'identity/api/Authentication/SignIn';
  String authenticateApiV2 = 'identity/api/Authentication/V2/SignIn';
  String registrationApi = 'api/registration';
  UserModel? user;
  bool isBiometricEnabled = false;
  final _logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
    output: FileLoggerOutput(), // Use the default LogOutput (-> send everything to console)
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
      ? await _internalAuthenticate(this.user!.email, this.user!.password)
      : await _internalAuthenticateV2(this.user!.email, this.user!.password);

  String getUserToken() => user!.token;

  Future<bool> authenticate(String email, String password) async {
    try {
      _logger.i('Authenticating...');
      var pass = await cryptographyService.encryptToAES(password);

      return isEmailAuthenticationType(email)
          ? await _internalAuthenticate(email, password)
          : await _internalAuthenticateV2(email, pass);
    } on Exception catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    var pass = await cryptographyService.encryptToAES(password);

    var response = await http.post(Uri.https(this.url, this.registrationApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'email': email, 'password': pass}));

    return response.statusCode == 200;
  }

  void logout() {
    this.user = null;
    this.userRepository.clear();
  }

  Future<bool> _internalAuthenticate(String email, String password) async {
    var response = await http.post(Uri.https(this.url, this.authenticateApi),
        headers: <String, String>{'Content-Type': 'application/json'},
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      jsonModel['password'] = password;
      this.user = UserModel.fromJson(jsonModel);
      this.userRepository.store(this.user!);
      this.notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _internalAuthenticateV2(String username, String password) async {
    var response = await http.post(Uri.https(this.url, this.authenticateApiV2),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{'username': username, 'password': password}));

    if (response.statusCode == 200) {
      var jsonModel = json.decode(response.body);
      jsonModel['password'] = password;
      this.user = UserModel.fromJson(jsonModel);
      this.userRepository.store(this.user!);
      this.notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  isEmailAuthenticationType(String email) {
    return email.contains('@');
  }
}
