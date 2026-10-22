import 'package:home_management_app/domain/models/account.dart';
import 'package:home_management_app/domain/models/category.dart';
import 'package:home_management_app/domain/models/currency.dart';
import 'package:home_management_app/domain/models/transaction.dart';

import 'local_database.dart';

extension LocalCurrencyMapping on LocalCurrency {
  CurrencyModel toModel() => CurrencyModel(id, name, value);
}

extension LocalAccountMapping on LocalAccount {
  /// Local accounts have no owner, so `userId` is 0.
  AccountModel toModel(double balance) => AccountModel(
      id,
      name,
      balance,
      measurable,
      accountTypeFromInt(accountType),
      currencyId,
      0,
      archive,
      isHidden);
}

extension LocalCategoryMapping on LocalCategory {
  CategoryModel toModel() =>
      CategoryModel(id, 0, name, icon, measurable, isActive, color);
}

extension LocalTransactionMapping on LocalTransaction {
  TransactionModel toModel(String categoryName) => TransactionModel(
      id,
      accountId,
      categoryId,
      name,
      amount,
      fromStoredDate(date),
      transactionTypeFromInt(transactionType),
      categoryName: categoryName);
}

/// Dates are stored as UTC midnight of the chosen day, like the server does.
/// Only the calendar day of [date] matters, whatever zone it is in.
DateTime toStoredDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

/// Hands the day back as local midnight, so views show the day that was chosen.
DateTime fromStoredDate(DateTime stored) {
  final utc = stored.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}

/// How the types are stored: the same numbers the server uses (`0` = Cash and
/// Income, `1` = BankAccount and Outcome). Kept here, next to what reads them back.
int accountTypeToInt(AccountType type) => type == AccountType.Cash ? 0 : 1;

AccountType accountTypeFromInt(int value) =>
    value == 1 ? AccountType.BankAccount : AccountType.Cash;

int transactionTypeToInt(TransactionType type) =>
    type == TransactionType.Income ? 0 : 1;

TransactionType transactionTypeFromInt(int value) =>
    value == 0 ? TransactionType.Income : TransactionType.Outcome;

/// A name for an account or a category: trimmed, and 1 to 100 characters.
String validName(String raw) {
  final name = raw.trim();
  if (name.isEmpty || name.length > 100) {
    throw ArgumentError.value(raw, 'name', 'must be 1 to 100 characters');
  }
  return name;
}
