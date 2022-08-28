import 'package:flutter/material.dart';
import 'package:home_management_app/models/user.dart';
import 'package:home_management_app/repositories/user.repository.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'cryptography.service.dart';

class AuthenticationService extends ChangeNotifier {
  CryptographyService cryptographyService;
  UserRepository userRepository;
  final LocalAuthentication auth = LocalAuthentication();
  String url = 'ramiro-di-rico.dev';
  String authenticateApi = 'identity/api/Authentication/SignIn';
  String registrationApi = 'api/registration';
  UserModel user;
  bool isBiometricEnabled = false;

  AuthenticationService(
      {@required this.cryptographyService, this.userRepository});

  Future init() async {
    this.user = await this.userRepository.load();

    if (!canAutoAuthenticate()) return;

    if (isAuthenticated()) {
      notifyListeners();
      return;
    }

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
    return user.expirationDate.isAfter(DateTime.now());
  }

  Future biometricsAuthenticate() async {
    var biometricAuthenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true);

    if (biometricAuthenticated) {
      await this.autoAuthenticate();
    }
  }

  Future autoAuthenticate() async =>
      await _internalAuthenticate(this.user.email, this.user.password);

  String getUserToken() => user.token;

  Future<bool> authenticate(String email, String password) async {
    var pass = await cryptographyService.encryptToAES(password);

    return await _internalAuthenticate(email, pass);
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
      this.user = UserModel.fromJson(json.decode(response.body));
      this.userRepository.store(this.user);
      this.notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
