import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/repositories/transaction.repository.dart';
import 'myapp.dart';
import 'repositories/account.repository.dart';
import 'repositories/category.repository.dart';
import 'repositories/notification.repository.dart';
import 'repositories/preferences.repository.dart';
import 'repositories/currency.repository.dart';
import 'repositories/user.repository.dart';
import 'services/api.service.factory.dart';
import 'services/authentication.service.dart';
import 'services/account.service.dart';
import 'services/caching.dart';
import 'services/category.service.dart';
import 'services/category.service.metric.dart';
import 'services/dashboard.service.dart';
import 'services/notification.service.dart';
import 'services/preferences.service.dart';
import 'services/cryptography.service.dart';
import 'services/currency.service.dart';
import 'services/metrics.service.dart';
import 'services/transaction.service.dart';

void main() {
  registerDependencies();
  runApp(MyApp());
}

void registerDependencies() {
  registerSingletons();
  registerServices();
}

void registerServices() {
  GetIt.instance.registerFactory(() => CryptographyService());
  GetIt.instance.registerFactory(() => TransactionService(
      authenticationService: GetIt.I<AuthenticationService>()));
  /*GetIt.instance.registerFactory(() {
    var authenticationService = GetIt.I<AuthenticationService>();
  });*/

  GetIt.instance.registerFactory(() => MetricService(
      caching: GetIt.I<Caching>(),
      authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => AccountService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));
  GetIt.instance.registerFactory(() => CategoryService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));
  GetIt.instance.registerFactory(() => ApiServiceFactory(
      authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => CurrencyService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));
  GetIt.instance.registerFactory(() => PreferenceService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));
  GetIt.instance.registerFactory(() => NotificationService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));

  GetIt.instance.registerFactory(() => DashboardService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>()),
      caching: GetIt.I<Caching>()));

  GetIt.instance.registerFactory(() => CategoryMetricService(
      authenticationService: GetIt.I<AuthenticationService>(),
      caching: GetIt.I<Caching>()));
}

void registerSingletons() {
  GetIt.instance.registerSingleton(Caching());

  CryptographyService cryptographyService = CryptographyService();
  var userRepository = UserRepository();
  AuthenticationService authenticationService = AuthenticationService(
      cryptographyService: cryptographyService, userRepository: userRepository);

  GetIt.instance.registerSingleton(authenticationService);

  AccountService accountService = AccountService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService));

  var accountRepository = AccountRepository(accountService: accountService);

  var currencyRepository = CurrencyRepository(
      currencyService: CurrencyService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var preferencesRepository = PreferencesRepository(
      preferenceService: PreferenceService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var notificationRepository = NotificationRepository(
      notificationService: NotificationService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var transactionService =
      TransactionService(authenticationService: authenticationService);

  var transactionRepository = TransactionRepository(
      transactionService: transactionService,
      accountRepository: accountRepository);

  var categoryRepository = CategoryRepository(CategoryService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService)));

  GetIt.instance.registerSingleton(userRepository);
  GetIt.instance.registerSingleton(accountRepository);
  GetIt.instance.registerSingleton(currencyRepository);
  GetIt.instance.registerSingleton(preferencesRepository);
  GetIt.instance.registerSingleton(notificationRepository);
  GetIt.instance.registerSingleton(transactionRepository);
  GetIt.instance.registerSingleton(categoryRepository);
}
