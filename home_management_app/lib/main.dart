import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'myapp.dart';
import 'repositories/account.repository.dart';
import 'repositories/notification.repository.dart';
import 'repositories/preferences.repository.dart';
import 'repositories/currency.repository.dart';
import 'repositories/user.repository.dart';
import 'services/authentication.service.dart';
import 'services/account.service.dart';
import 'services/caching.dart';
import 'services/notification.service.dart';
import 'services/preferences.service.dart';
import 'services/cryptography.service.dart';
import 'services/currency.service.dart';
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
  var currencyService = CurrencyService(authenticationService: authenticationService);
  var currencyRepository = CurrencyRepository(currencyService: currencyService);
  var preferenceService = PreferenceService(authenticationService: authenticationService);
  var preferencesRepository = PreferencesRepository(preferenceService: preferenceService);

  var notificationService = NotificationService(authenticationService: authenticationService);
  var notificationRepository = NotificationRepository(notificationService: notificationService);

  GetIt.instance.registerFactory(() => CryptographyService());
  GetIt.instance.registerFactory(() => Caching());
  GetIt.instance.registerFactory(() => metricService);
  GetIt.instance.registerFactory(() => accountService);
  GetIt.instance.registerFactory(() => currencyService);
  GetIt.instance.registerFactory(() => preferenceService);
  GetIt.instance.registerFactory(() => notificationService);
  GetIt.instance.registerSingleton(userRepository);
  GetIt.instance.registerSingleton(accountRepository);
  GetIt.instance.registerSingleton(authenticationService);
  GetIt.instance.registerSingleton(currencyRepository);
  GetIt.instance.registerSingleton(preferencesRepository);
  GetIt.instance.registerSingleton(notificationRepository);
  
}