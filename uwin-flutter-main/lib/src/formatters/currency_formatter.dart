import 'package:intl/intl.dart';

class CurrencyFormatter {
  final NumberFormat _formatter;

  CurrencyFormatter({symbol = "Rs ", decimalDigits: 2})
      : _formatter = NumberFormat.currency(
          symbol: symbol,
          decimalDigits: decimalDigits,
        );

  String format(int amount) {
    return _formatter.format(amount / 100);
  }
}
