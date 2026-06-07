import 'package:flutter_test/flutter_test.dart';
import 'package:home_management_app/custom/formatters/localized_number_input_formatter.dart';

void main() {
  group('LocalizedNumberInputFormatterHelper', () {
    test('formats English numbers with thousands separators', () {
      expect(
        LocalizedNumberInputFormatterHelper.formatInput(
          '200000',
          decimalSeparator: '.',
          groupSeparator: ',',
        ),
        '200,000',
      );
    });

    test('formats German numbers with thousands separators and decimal comma', () {
      expect(
        LocalizedNumberInputFormatterHelper.formatInput(
          '200000,56',
          decimalSeparator: ',',
          groupSeparator: '.',
        ),
        '200.000,56',
      );
    });

    test('preserves trailing decimal separator while typing', () {
      expect(
        LocalizedNumberInputFormatterHelper.formatInput(
          '1234,',
          decimalSeparator: ',',
          groupSeparator: '.',
        ),
        '1.234,',
      );
    });

    test('parses localized German numbers', () {
      expect(
        LocalizedNumberInputFormatterHelper.parseDouble('200.000,56', 'de_DE'),
        200000.56,
      );
    });

    test('parses localized English numbers', () {
      expect(
        LocalizedNumberInputFormatterHelper.parseDouble('200,000.56', 'en_US'),
        200000.56,
      );
    });

    test('formats doubles using the locale separators', () {
      expect(
        LocalizedNumberInputFormatterHelper.formatDouble(200000.56, 'en_US'),
        '200,000.56',
      );
      expect(
        LocalizedNumberInputFormatterHelper.formatDouble(200000.56, 'de_DE'),
        '200.000,56',
      );
    });
  });

  group('LocalizedNumberInputFormatter', () {
    test('formats text while typing', () {
      final formatter = LocalizedNumberInputFormatter(locale: 'de_DE');
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        const TextEditingValue(text: '200000'),
      );

      expect(result.text, '200.000');
    });
  });
}


