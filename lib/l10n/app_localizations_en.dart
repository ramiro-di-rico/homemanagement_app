// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Home Management';

  @override
  String get userSettings => 'User Settings';

  @override
  String get csvDelimiter => 'CSV Delimiter';

  @override
  String get preferredCurrency => 'Preferred Currency';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get accounts => 'Accounts';

  @override
  String get mainAccounts => 'Main Accounts';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get authenticationSettings => 'Authentication Settings';

  @override
  String get username => 'Username';

  @override
  String get enableTwoFactorAuthentication =>
      'Enable Two Factor Authentication';

  @override
  String get balance => 'Balance';

  @override
  String get noBalanceInformation => 'No balance information available';

  @override
  String get overall => 'Overall';

  @override
  String get noTransactionsRecorded => 'No transactions recorded yet';

  @override
  String get count => 'Count';

  @override
  String get total => 'Total';

  @override
  String get income => 'Income';

  @override
  String get outcome => 'Outcome';

  @override
  String get expense => 'Expense';

  @override
  String get noBalanceHistory => 'No balance history available yet';

  @override
  String get balanceHistory => 'Balance History';

  @override
  String get allCurrencies => 'All Currencies';

  @override
  String get all => 'All';

  @override
  String get months => 'Months';

  @override
  String removed(String name) {
    return '$name removed';
  }

  @override
  String failedToRemove(String name) {
    return 'Failed to remove $name';
  }

  @override
  String get showMenu => 'Show menu';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get archive => 'Archive';

  @override
  String get importTransactions => 'Import Transactions';

  @override
  String get noTransactionsFoundForAccount =>
      'No transactions found for this account';

  @override
  String get filterByName => 'Filter by name';

  @override
  String get transactionsImportedSuccessfully =>
      'Transactions imported successfully';

  @override
  String get failedToImportTransactions => 'Failed to import transactions';

  @override
  String get signIn => 'Sign in';

  @override
  String get logout => 'Logout';

  @override
  String get dontHaveAccount => 'You don\'t have an account yet ?';

  @override
  String get createOne => 'Create one';

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get password => 'Password';

  @override
  String get addAccount => 'Add Account';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get delete => 'Delete';

  @override
  String get unassign => 'Unassign';

  @override
  String addAccountTo(String name) {
    return 'Add Account to $name';
  }

  @override
  String get noMoreAccountsAvailable => 'No more accounts available to add.';

  @override
  String get close => 'Close';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String areYouSureDelete(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String deleted(String name) {
    return '$name deleted';
  }

  @override
  String get budget => 'Budget';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get bulkTransactions => 'Bulk transactions';

  @override
  String get loggingView => 'Logging View';

  @override
  String get statistics => 'Statistics';

  @override
  String get name => 'Name';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get rejectSubmissions => 'Reject submissions';

  @override
  String get reject => 'Reject';

  @override
  String get invitationQr => 'Invitation QR';

  @override
  String get invitations => 'Invitations';

  @override
  String get createInvitation => 'Create invitation';

  @override
  String get invitationDescription =>
      'One account, one invitation. External users submit transactions for later approval.';

  @override
  String get clearDate => 'Clear date';

  @override
  String get noInvitationsYet => 'No invitations yet.';

  @override
  String get sortAndFilter => 'Sort and filter';

  @override
  String get createdDate => 'Created date';

  @override
  String get expirationDate => 'Expiration date';

  @override
  String get allInvites => 'All invites';

  @override
  String get hasExpiration => 'Has expiration';

  @override
  String get noExpiration => 'No expiration';

  @override
  String get allAccounts => 'All accounts';

  @override
  String get allCategories => 'All categories';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get invitation => 'Invitation';

  @override
  String get invitationUnavailable => 'This invitation is unavailable.';

  @override
  String categoryName(String name) {
    return 'Category: $name';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String expiresLabel(String date) {
    return 'Expires: $date';
  }

  @override
  String get submitTransaction => 'Submit transaction';

  @override
  String get submitForApproval => 'Submit for approval';

  @override
  String accountLabel(String name) {
    return 'Account: $name';
  }

  @override
  String get exportTransactions => 'Export transactions';

  @override
  String get downloadImportTemplate => 'Download import template';

  @override
  String get templateDownloaded => 'Template downloaded';

  @override
  String get failedToDownloadTemplate => 'Failed to download template';

  @override
  String get registration => 'Registration';

  @override
  String get authenticationError => 'Authentication error.';

  @override
  String get couldNotAuthenticateAfterRegistration =>
      'Could not authenticate user after registration.';

  @override
  String get showAllAccounts => 'Show all accounts';

  @override
  String get hideAccounts => 'Hide accounts';

  @override
  String get searchAccounts => 'Search accounts';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get searchRecurringTransactions => 'Search recurring transactions';

  @override
  String get addRecurringTransaction => 'Add recurring transaction';

  @override
  String get noRecurringTransactionsFound => 'No recurring transactions found';

  @override
  String get pageSize => 'Page size';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get filterTransactions => 'Filter transactions';

  @override
  String get selectFilterToDisplayTransactions =>
      'Select a filter to display transactions';

  @override
  String get searchTransactionByName => 'Search transaction by name';

  @override
  String get selectOption => 'Select';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get selectAccount => 'Select account';

  @override
  String get selectAccounts => 'Select accounts';

  @override
  String get selectCategory => 'Select category';

  @override
  String get selectCategories => 'Select categories';

  @override
  String get selectAll => 'Select all';

  @override
  String get filter => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get ok => 'Ok';

  @override
  String get unknownAccount => 'Unknown account';

  @override
  String get accountNotSet => 'Account not set';

  @override
  String get categoryNotSet => 'Category not set';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get priceNotSet => 'Price not set';

  @override
  String get annually => 'Annually';
}
