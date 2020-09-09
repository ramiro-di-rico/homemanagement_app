import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'myapp.dart';
import 'repositories/account.repository.dart';
import 'services/authentication.service.dart';
import 'services/account.service.dart';
import 'services/caching.dart';
import 'services/cryptography.service.dart';
import 'services/metrics.service.dart';
import 'services/user.store.dart';

void main() {
  registerDependencies();
  runApp(MyApp());
}

void registerDependencies(){
  UserStore userStore = UserStore();
  CryptographyService cryptographyService = CryptographyService();
  Caching caching = Caching();
  AuthenticationService authenticationService = AuthenticationService(cryptographyService: cryptographyService, userStore: userStore);
  AccountService accountService = AccountService(authenticationService: authenticationService, caching: caching);  
  var accountRepository = AccountRepository(accountService: accountService, caching: caching);
  var metricService = MetricService(caching: caching, authenticationService: authenticationService);

  GetIt.instance.registerFactory(() => userStore);
  GetIt.instance.registerFactory(() => CryptographyService());
  GetIt.instance.registerFactory(() => Caching());
  GetIt.instance.registerFactory(() => metricService);
  GetIt.instance.registerSingleton(authenticationService);
  GetIt.instance.registerFactory(() => accountService);
  GetIt.instance.registerSingleton(accountRepository);
}