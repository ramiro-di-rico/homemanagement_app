import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'myapp.dart';
import 'package:home_management_app/data/services/main_account.service.dart';
import 'package:home_management_app/data/services/budget_http_service.dart';
import 'package:home_management_app/data/services/identity.service.dart';
import 'package:home_management_app/data/services/identity_user_service.dart';
import 'package:home_management_app/data/services/invite.service.dart';
import 'package:home_management_app/data/services/public_invite.service.dart';
import 'package:home_management_app/data/services/deep_link_service.dart';
import 'package:home_management_app/data/services/recurring_transaction_service.dart';
import 'package:home_management_app/data/services/reminder_service.dart';
import 'package:home_management_app/data/services/user-settings-service.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/data/services/platform/platform_context.dart';
import 'package:home_management_app/data/services/platform/platform_strategy.dart';
import 'package:home_management_app/data/repositories/account.repository.dart';
import 'package:home_management_app/data/repositories/budget_repository.dart';
import 'package:home_management_app/data/repositories/category.repository.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';
import 'package:home_management_app/data/repositories/invite.repository.dart';
import 'package:home_management_app/data/repositories/notification.repository.dart';
import 'package:home_management_app/data/repositories/currency.repository.dart';
import 'package:home_management_app/data/repositories/main_account.repository.dart';
import 'package:home_management_app/data/repositories/recurring_transaction_repository.dart';
import 'package:home_management_app/data/repositories/reminder_repository.dart';
import 'package:home_management_app/data/repositories/tag.repository.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/repositories/user.repository.dart';
import 'package:home_management_app/data/services/api.service.factory.dart';
import 'package:home_management_app/data/services/authentication.service.dart';
import 'package:home_management_app/data/services/account.service.dart';
import 'package:home_management_app/data/services/caching.dart';
import 'package:home_management_app/data/services/category.service.dart';
import 'package:home_management_app/data/services/category.service.metric.dart';
import 'package:home_management_app/data/services/dashboard.service.dart';
import 'package:home_management_app/data/services/notification.service.dart';
import 'package:home_management_app/data/services/cryptography.service.dart';
import 'package:home_management_app/data/services/currency.service.dart';
import 'package:home_management_app/data/services/metrics.service.dart';
import 'package:home_management_app/data/services/tag.service.dart';
import 'package:home_management_app/data/services/transaction.service.dart';
import 'package:home_management_app/data/services/password_reset_service.dart';
import 'package:home_management_app/data/services/transaction_paging_service.dart';
import 'package:home_management_app/data/services/invite_link_service.dart';

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

  GetIt.instance.registerFactory(() => TagService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>()),
      notifierService: GetIt.I<NotifierService>()));

  GetIt.instance.registerFactory(() => IdentityUserService(authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => InviteService(
      authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => PublicInviteService());

  GetIt.instance.registerFactory(() => RecurringTransactionService(authenticationService: GetIt.I<AuthenticationService>()));

  GetIt.instance.registerFactory(() => IdentityService(null));

  GetIt.instance.registerFactory(() => BudgetHttpService(apiServiceFactory: ApiServiceFactory(authenticationService: GetIt.I<AuthenticationService>())));

  GetIt.instance.registerFactory(() => MainAccountService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(
          authenticationService: GetIt.I<AuthenticationService>())));

  GetIt.instance.registerFactory(() => UserSettingsService(
      authenticationService: GetIt.I<AuthenticationService>(),
      apiServiceFactory: ApiServiceFactory(authenticationService: GetIt.I<AuthenticationService>()),
      notifierService: GetIt.I<NotifierService>()));
}

void registerSingletons(PlatformContext platformContext) {
  var errorNotifierService = NotifierService();
  GetIt.instance.registerSingleton(Caching());

  CryptographyService cryptographyService = CryptographyService();
  var userRepository = UserRepository();
  AuthenticationService authenticationService = AuthenticationService(
      cryptographyService, userRepository,
      platformContext,
      errorNotifierService,
      null);

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


  var notificationRepository = NotificationRepository(
      notificationService: NotificationService(
          authenticationService: GetIt.I<AuthenticationService>(),
          apiServiceFactory: ApiServiceFactory(
              authenticationService: GetIt.I<AuthenticationService>())));

  var transactionService =
      TransactionService(authenticationService: authenticationService);

  var tagRepository = TagRepository(TagService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService),
      notifierService: errorNotifierService));

  var transactionRepository = TransactionRepository(
      transactionService: transactionService,
      accountRepository: accountRepository,
      errorNotifierService: errorNotifierService,
      tagRepository: tagRepository);

  var categoryRepository = CategoryRepository(CategoryService(
      authenticationService: authenticationService,
      apiServiceFactory:
          ApiServiceFactory(authenticationService: authenticationService),
      notifierService: errorNotifierService));

  var identityUserRepository = IdentityUserRepository(
      IdentityUserService(authenticationService: authenticationService),
      userRepository);

  var transactionPagingService = TransactionPagingService(transactionService);
  var inviteRepository = InviteRepository(
      inviteService: InviteService(authenticationService: authenticationService),
      notifierService: errorNotifierService);
  var recurringTransactionRepository = RecurringTransactionRepository(
      RecurringTransactionService(authenticationService: authenticationService),
      errorNotifierService);

  var passwordResetService = PasswordResetService();
  var deepLinkService = DeepLinkService();

  var budgetRepository = BudgetRepository(errorNotifierService, BudgetHttpService(apiServiceFactory: ApiServiceFactory(authenticationService: authenticationService)));

  var reminderRepository = ReminderRepository(ReminderService(GetIt.I<AuthenticationService>()), errorNotifierService);

  MainAccountService mainAccountService = MainAccountService(
      authenticationService: authenticationService,
      apiServiceFactory:
      ApiServiceFactory(authenticationService: authenticationService));

  var mainAccountRepository = MainAccountRepository(mainAccountService: mainAccountService, notifierService: errorNotifierService);

  GetIt.instance.registerSingleton(platformContext);
  GetIt.instance.registerSingleton(userRepository);
  GetIt.instance.registerSingleton(accountRepository);
  GetIt.instance.registerSingleton(currencyRepository);
  GetIt.instance.registerSingleton(notificationRepository);
  GetIt.instance.registerSingleton(transactionRepository);
  GetIt.instance.registerSingleton(categoryRepository);
  GetIt.instance.registerSingleton(tagRepository);
  GetIt.instance.registerSingleton(errorNotifierService);
  GetIt.instance.registerSingleton(identityUserRepository);
  GetIt.instance.registerSingleton(transactionPagingService);
  GetIt.instance.registerSingleton(inviteRepository);
  GetIt.instance.registerSingleton(recurringTransactionRepository);
  GetIt.instance.registerSingleton(passwordResetService);
  GetIt.instance.registerSingleton(deepLinkService);
  GetIt.instance.registerSingleton(budgetRepository);
  GetIt.instance.registerSingleton(reminderRepository);
  GetIt.instance.registerSingleton(mainAccountRepository);
  GetIt.instance.registerSingleton(InviteLinkService());
}
