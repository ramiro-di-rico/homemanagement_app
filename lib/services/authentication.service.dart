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

  AuthenticationService(
      {@required this.cryptographyService, this.userRepository});

  init() {
    this.user = this.userRepository.userModel;
    this.user.expirationDate =
        this.user.expirationDate.subtract(Duration(hours: 5));
  }

  bool canAutoAuthenticate() {
    return user != null;
  }

  bool isAuthenticated() {
    return user.expirationDate.isAfter(DateTime.now());
  }

  Future<bool> biometricsEnabled() async => await auth.canCheckBiometrics;

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
