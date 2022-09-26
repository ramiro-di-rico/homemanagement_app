import 'package:home_management_app/converters/shorten-big-number.dart';

class DoubleShortenConverter implements ShortenBigNumber<double> {
  @override
  String shortNumber(double value) {
    if (value > 999 && value < 999999) return (value / 1000).toString() + ' K';

    if (value > 999999) return (value / 1000000).toStringAsFixed(2) + ' M';

    return value.toString();
  }
}
