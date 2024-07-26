import 'package:flutter/cupertino.dart';
import '../formatters/currency_formatter.dart';

class CurrencyNumberFormat extends StatelessWidget {
  CurrencyNumberFormat({
    this.number,
    this.style,
    this.overflow,
    int decimalDigits = 2,
    String symbol = 'Rs ',
  }) : _formatter = CurrencyFormatter(
          symbol: symbol,
          decimalDigits: decimalDigits,
        );

  final num number;
  final TextStyle style;
  final TextOverflow overflow;
  final _formatter;

  @override
  Widget build(BuildContext context) {
    final formattedVal = number < 0
        ? '(${_formatter.format(-1 * number)})'
        : _formatter.format(number);

    return Text(formattedVal, style: style, overflow: overflow);
  }
}
