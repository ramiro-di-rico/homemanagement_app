import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'myapp.dart';
import 'services/endpoints/identity_user_service.dart';
import 'services/endpoints/recurring_transaction_service.dart';
import 'services/infra/error_notifier_service.dart';
import 'services/infra/platform/platform_context.dart';
import 'services/infra/platform/platform_strategy.dart';
import 'services/repositories/account.repository.dart';
import 'services/repositories/category.repository.dart';
import 'services/repositories/identity_user_repository.dart';
import 'services/repositories/notification.repository.dart';
import 'services/repositories/preferences.repository.dart';
import 'services/repositories/currency.repository.dart';
import 'services/repositories/recurring_transaction_repository.dart';
import 'services/repositories/transaction.repository.dart';
import 'services/repositories/user.repository.dart';
import 'services/endpoints/api.service.factory.dart';
import 'services/security/authentication.service.dart';
import 'services/endpoints/account.service.dart';
import 'services/infra/caching.dart';
import 'services/endpoints/category.service.dart';
import 'services/endpoints/category.service.metric.dart';
import 'services/endpoints/dashboard.service.dart';
import 'services/endpoints/notification.service.dart';
import 'services/endpoints/preferences.service.dart';
import 'services/infra/cryptography.service.dart';
import 'services/endpoints/currency.service.dart';
import 'services/endpoints/metrics.service.dart';
import 'services/endpoints/transaction.service.dart';
import 'services/transaction_paging_service.dart';

void main() {
  var platform = PlatformStrategy.createPlatform();
  platform.initialize();
  registerDependencies(platform);
  runApp(MyApp(platform));
}

void registerDependencies(PlatformContext platform) {
  registerSingletons(platform);
  registerServices();
}

void registerServices() {
  GetIt.instance.registerFactory(() => CryptographyService());
  GetIt.instance.registerFactory(() => TransactionService(
      authenticationService: GetIt.I<AuthenticationService>()));

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
          authenticationService: GetIt.I<AuthenticationService>()),
      notifierService: GetIt.I<NotifierService>()));
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

  GetIt.instance.registerFactory(() => IdentityUserService(authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => RecurringTransactionService(authenticationService: GetIt.I<AuthenticationService>()));
}

void registerSingletons(PlatformContext platformContext) {
  var errorNotifierService = NotifierService();
  GetIt.instance.registerSingleton(Caching());

  CryptographyService cryptographyService = CryptographyService();
  var userRepository = UserRepository();
  AuthenticationService authenticationService = AuthenticationService(
      cryptographyService: cryptographyService, userRepository: userRepository,
      platformContext: platformContext,
      notifierService: errorNotifierService);

  GetIt.instance.registerSingleton(authenticationService);

  AccountService accountService = AccountService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService));

  var accountRepository = AccountRepository(accountService: accountService, notifierService: errorNotifierService);

  var currencyRepository = CurrencyRepository(
      currencyService: CurrencyService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var preferencesRepository = PreferencesRepository(
      preferenceService: PreferenceService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())),
      notifierService: errorNotifierService);

  var notificationRepository = NotificationRepository(
      notificationService: NotificationService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var transactionService =
      TransactionService(authenticationService: authenticationService);

  var transactionRepository = TransactionRepository(
      transactionService: transactionService,
      accountRepository: accountRepository,
      errorNotifierService: errorNotifierService);

  var categoryRepository = CategoryRepository(CategoryService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService),
      notifierService: errorNotifierService));

  var identityUserRepository = IdentityUserRepository(
      IdentityUserService(authenticationService: authenticationService));

  var transactionPagingService = TransactionPagingService(transactionService);
  var recurringTransactionRepository = RecurringTransactionRepository(
      RecurringTransactionService(authenticationService: authenticationService),
      errorNotifierService);

  GetIt.instance.registerSingleton(platformContext);
  GetIt.instance.registerSingleton(userRepository);
  GetIt.instance.registerSingleton(accountRepository);
  GetIt.instance.registerSingleton(currencyRepository);
  GetIt.instance.registerSingleton(preferencesRepository);
  GetIt.instance.registerSingleton(notificationRepository);
  GetIt.instance.registerSingleton(transactionRepository);
  GetIt.instance.registerSingleton(categoryRepository);
  GetIt.instance.registerSingleton(errorNotifierService);
  GetIt.instance.registerSingleton(identityUserRepository);
  GetIt.instance.registerSingleton(transactionPagingService);
  GetIt.instance.registerSingleton(recurringTransactionRepository);
}
