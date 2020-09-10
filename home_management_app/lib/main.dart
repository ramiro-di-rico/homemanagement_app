import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'myapp.dart';
import 'repositories/account.repository.dart';
import 'repositories/user.repository.dart';
import 'services/authentication.service.dart';
import 'services/account.service.dart';
import 'services/caching.dart';
import 'services/cryptography.service.dart';
import 'services/metrics.service.dart';

void main() {
  registerDependencies();
  runApp(MyApp());
}

void registerDependencies(){
  CryptographyService cryptographyService = CryptographyService();
  Caching caching = Caching();
  var userRepository = UserRepository();
  AuthenticationService authenticationService = AuthenticationService(cryptographyService: cryptographyService, userRepository: userRepository);
  AccountService accountService = AccountService(authenticationService: authenticationService);  
  var accountRepository = AccountRepository(accountService: accountService);
  var metricService = MetricService(caching: caching, authenticationService: authenticationService);

  GetIt.instance.registerSingleton(userRepository);
  GetIt.instance.registerFactory(() => CryptographyService());
  GetIt.instance.registerFactory(() => Caching());
  GetIt.instance.registerFactory(() => metricService);
  GetIt.instance.registerSingleton(authenticationService);
  GetIt.instance.registerFactory(() => accountService);
  GetIt.instance.registerSingleton(accountRepository);
}