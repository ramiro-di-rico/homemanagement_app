import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LocalizedNumberInputFormatter extends TextInputFormatter {
  LocalizedNumberInputFormatter({required String locale, this.decimalDigits = 2})
      : decimalSeparator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP,
        groupSeparator = NumberFormat.decimalPattern(locale).symbols.GROUP_SEP;

  final String decimalSeparator;
  final String groupSeparator;
  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = LocalizedNumberInputFormatterHelper.formatInput(
      newValue.text,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
      decimalDigits: decimalDigits,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class LocalizedNumberInputFormatterHelper {
  static String formatDouble(double value, String locale, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern(locale);
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static double? parseDouble(String text, String locale) {
    final symbols = NumberFormat.decimalPattern(locale).symbols;
    final cleaned = text.replaceAll(RegExp(r'[\s\u00A0]'), '');

    if (cleaned.isEmpty) {
      return null;
    }

    final normalized = cleaned
        .replaceAll(symbols.GROUP_SEP, '')
        .replaceAll(symbols.DECIMAL_SEP, '.');

    return double.tryParse(normalized);
  }

  static String formatInput(
    String text, {
    required String decimalSeparator,
    required String groupSeparator,
    int decimalDigits = 2,
  }) {
    final cleaned = text.replaceAll(RegExp(r'[\s\u00A0]'), '');

    if (cleaned.isEmpty) {
      return '';
    }

    final decimalMarker = _findDecimalMarker(
      cleaned,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
    );

    final integerDigits = StringBuffer();
    final fractionDigits = StringBuffer();
    var inFraction = false;

    for (var index = 0; index < cleaned.length; index++) {
      final character = cleaned[index];

      if (_isDigit(character)) {
        if (inFraction) {
          if (fractionDigits.length < decimalDigits) {
            fractionDigits.write(character);
          }
        } else {
          integerDigits.write(character);
        }
        continue;
      }

      if (decimalMarker != null && character == decimalMarker && !inFraction) {
        inFraction = true;
      }
    }

    final integerPart = integerDigits.isEmpty ? '0' : integerDigits.toString();
    final groupedInteger = _groupDigits(integerPart, groupSeparator);
    final fractionPart = fractionDigits.toString();

    if (decimalMarker == null) {
      return groupedInteger;
    }

    if (cleaned.endsWith(decimalMarker) && fractionPart.isEmpty) {
      return '$groupedInteger$decimalSeparator';
    }

    if (fractionPart.isEmpty) {
      return groupedInteger;
    }

    return '$groupedInteger$decimalSeparator$fractionPart';
  }

  static String? _findDecimalMarker(
    String text, {
    required String decimalSeparator,
    required String groupSeparator,
  }) {
    if (text.contains(decimalSeparator)) {
      return decimalSeparator;
    }

    final dotCount = '.'.allMatches(text).length;
    if (dotCount == 1 && decimalSeparator != '.' && groupSeparator != '.') {
      return '.';
    }

    final commaCount = ','.allMatches(text).length;
    if (commaCount == 1 && decimalSeparator != ',' && groupSeparator != ',') {
      return ',';
    }

    return null;
  }

  static bool _isDigit(String character) {
    return character.codeUnitAt(0) >= 48 && character.codeUnitAt(0) <= 57;
  }

  static String _groupDigits(String digits, String groupSeparator) {
    if (digits.length <= 3) {
      return digits;
    }

    final reversed = digits.split('').reversed.toList();
    final buffer = StringBuffer();

    for (var index = 0; index < reversed.length; index++) {
      if (index > 0 && index % 3 == 0) {
        buffer.write(groupSeparator);
      }
      buffer.write(reversed[index]);
    }

    return buffer.toString().split('').reversed.join();
  }
}

