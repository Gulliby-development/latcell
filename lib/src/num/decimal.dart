import '../base/failure.dart';
import 'frac.dart';

Frac parseDecimal(String text, String what, int lo, int hi) {
  final codeUnits = text.codeUnits;
  var index = 0;
  var negative = false;

  if (index < codeUnits.length &&
      (codeUnits[index] == 0x2b || codeUnits[index] == 0x2d)) {
    negative = codeUnits[index] == 0x2d;
    index++;
  }

  final integerStart = index;
  while (index < codeUnits.length &&
      codeUnits[index] >= 0x30 &&
      codeUnits[index] <= 0x39) {
    index++;
  }
  final hasIntegerDigits = index > integerStart;

  var decimalPlaces = 0;
  if (index < codeUnits.length && codeUnits[index] == 0x2e) {
    index++;
    final fractionStart = index;
    while (index < codeUnits.length &&
        codeUnits[index] >= 0x30 &&
        codeUnits[index] <= 0x39) {
      index++;
    }
    decimalPlaces = index - fractionStart;
    if (decimalPlaces == 0) {
      throw Failure(1, '$what $text is not a decimal number');
    }
  }

  if (!hasIntegerDigits || index != codeUnits.length) {
    throw Failure(1, '$what $text is not a decimal number');
  }
  if (decimalPlaces > 12) {
    throw Failure(1, '$what $text has more than 12 decimals');
  }

  final signOffset = text.startsWith('+') || text.startsWith('-') ? 1 : 0;
  final digits = text.substring(signOffset).replaceAll('.', '');
  var numerator = BigInt.parse(digits);
  if (negative) {
    numerator = -numerator;
  }
  final value = Frac(numerator, BigInt.from(10).pow(decimalPlaces));

  if (value < Frac.of(lo) || value > Frac.of(hi)) {
    throw Failure(1, '$what $text is outside $lo..$hi');
  }
  return value;
}

Frac parseLat(String text) => parseDecimal(text, 'latitude', -90, 90);

Frac parseLon(String text) => parseDecimal(text, 'longitude', -180, 180);
