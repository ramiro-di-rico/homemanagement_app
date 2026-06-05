import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('es', 'AR'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Home Management'**
  String get appTitle;

  /// User Settings section title
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// Label for CSV Delimiter setting
  ///
  /// In en, this message translates to:
  /// **'CSV Delimiter'**
  String get csvDelimiter;

  /// Label for Preferred Currency setting
  ///
  /// In en, this message translates to:
  /// **'Preferred Currency'**
  String get preferredCurrency;

  /// Label for Backup Frequency setting
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFrequency;

  /// Weekly backup frequency
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly backup frequency
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Label for App Language setting
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @mainAccounts.
  ///
  /// In en, this message translates to:
  /// **'Main Accounts'**
  String get mainAccounts;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @authenticationSettings.
  ///
  /// In en, this message translates to:
  /// **'Authentication Settings'**
  String get authenticationSettings;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enableTwoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Enable Two Factor Authentication'**
  String get enableTwoFactorAuthentication;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @noBalanceInformation.
  ///
  /// In en, this message translates to:
  /// **'No balance information available'**
  String get noBalanceInformation;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @noTransactionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded yet'**
  String get noTransactionsRecorded;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @outcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get outcome;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @noBalanceHistory.
  ///
  /// In en, this message translates to:
  /// **'No balance history available yet'**
  String get noBalanceHistory;

  /// No description provided for @balanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Balance History'**
  String get balanceHistory;

  /// No description provided for @allCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All Currencies'**
  String get allCurrencies;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removed(String name);

  /// No description provided for @failedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove {name}'**
  String failedToRemove(String name);

  /// No description provided for @showMenu.
  ///
  /// In en, this message translates to:
  /// **'Show menu'**
  String get showMenu;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @importTransactions.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get importTransactions;

  /// No description provided for @noTransactionsFoundForAccount.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this account'**
  String get noTransactionsFoundForAccount;

  /// No description provided for @filterByName.
  ///
  /// In en, this message translates to:
  /// **'Filter by name'**
  String get filterByName;

  /// No description provided for @transactionsImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transactions imported successfully'**
  String get transactionsImportedSuccessfully;

  /// No description provided for @failedToImportTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to import transactions'**
  String get failedToImportTransactions;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account yet ?'**
  String get dontHaveAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get emailOrUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @unassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get unassign;

  /// No description provided for @addAccountTo.
  ///
  /// In en, this message translates to:
  /// **'Add Account to {name}'**
  String addAccountTo(String name);

  /// No description provided for @noMoreAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No more accounts available to add.'**
  String get noMoreAccountsAvailable;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String areYouSureDelete(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String deleted(String name);

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// No description provided for @bulkTransactions.
  ///
  /// In en, this message translates to:
  /// **'Bulk transactions'**
  String get bulkTransactions;

  /// No description provided for @loggingView.
  ///
  /// In en, this message translates to:
  /// **'Logging View'**
  String get loggingView;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @rejectSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Reject submissions'**
  String get rejectSubmissions;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @invitationQr.
  ///
  /// In en, this message translates to:
  /// **'Invitation QR'**
  String get invitationQr;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @createInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create invitation'**
  String get createInvitation;

  /// No description provided for @invitationDescription.
  ///
  /// In en, this message translates to:
  /// **'One account, one invitation. External users submit transactions for later approval.'**
  String get invitationDescription;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @noInvitationsYet.
  ///
  /// In en, this message translates to:
  /// **'No invitations yet.'**
  String get noInvitationsYet;

  /// No description provided for @sortAndFilter.
  ///
  /// In en, this message translates to:
  /// **'Sort and filter'**
  String get sortAndFilter;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created date'**
  String get createdDate;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDate;

  /// No description provided for @allInvites.
  ///
  /// In en, this message translates to:
  /// **'All invites'**
  String get allInvites;

  /// No description provided for @hasExpiration.
  ///
  /// In en, this message translates to:
  /// **'Has expiration'**
  String get hasExpiration;

  /// No description provided for @noExpiration.
  ///
  /// In en, this message translates to:
  /// **'No expiration'**
  String get noExpiration;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allAccounts;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @invitation.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get invitation;

  /// No description provided for @invitationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This invitation is unavailable.'**
  String get invitationUnavailable;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String categoryName(String name);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @expiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expiresLabel(String date);

  /// No description provided for @submitTransaction.
  ///
  /// In en, this message translates to:
  /// **'Submit transaction'**
  String get submitTransaction;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval'**
  String get submitForApproval;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account: {name}'**
  String accountLabel(String name);

  /// No description provided for @exportTransactions.
  ///
  /// In en, this message translates to:
  /// **'Export transactions'**
  String get exportTransactions;

  /// No description provided for @downloadImportTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download import template'**
  String get downloadImportTemplate;

  /// No description provided for @templateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Template downloaded'**
  String get templateDownloaded;

  /// No description provided for @failedToDownloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to download template'**
  String get failedToDownloadTemplate;

  /// No description provided for @registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error.'**
  String get authenticationError;

  /// No description provided for @couldNotAuthenticateAfterRegistration.
  ///
  /// In en, this message translates to:
  /// **'Could not authenticate user after registration.'**
  String get couldNotAuthenticateAfterRegistration;

  /// No description provided for @showAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'Show all accounts'**
  String get showAllAccounts;

  /// No description provided for @hideAccounts.
  ///
  /// In en, this message translates to:
  /// **'Hide accounts'**
  String get hideAccounts;

  /// No description provided for @searchAccounts.
  ///
  /// In en, this message translates to:
  /// **'Search accounts'**
  String get searchAccounts;

  /// No description provided for @developerMode.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get developerMode;

  /// No description provided for @recurringTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringTransactions;

  /// No description provided for @searchRecurringTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search recurring transactions'**
  String get searchRecurringTransactions;

  /// No description provided for @addRecurringTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add recurring transaction'**
  String get addRecurringTransaction;

  /// No description provided for @noRecurringTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions found'**
  String get noRecurringTransactionsFound;

  /// No description provided for @accountNotSet.
  ///
  /// In en, this message translates to:
  /// **'Account not set'**
  String get accountNotSet;

  /// No description provided for @categoryNotSet.
  ///
  /// In en, this message translates to:
  /// **'Category not set'**
  String get categoryNotSet;

  /// No description provided for @createTransaction.
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;

  /// No description provided for @priceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Price not set'**
  String get priceNotSet;

  /// No description provided for @annually.
  ///
  /// In en, this message translates to:
  /// **'Annually'**
  String get annually;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case 'AR':
            return AppLocalizationsEsAr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
