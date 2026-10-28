import '../base/failure.dart';
import '../base/text.dart';
import '../cell/cell.dart';
import '../num/frac.dart';

const String _alphabet = '23456789CFGHJMPQRVWX';
const int _latitudeUnitsPerDegree = 25000000;
const int _longitudeUnitsPerDegree = 8192000;
const int _latitudeUnitCount = 180 * _latitudeUnitsPerDegree;
const int _longitudeUnitCount = 360 * _longitudeUnitsPerDegree;

String encodeOlc(Frac lat, Frac lon, int length) {
  final latitudeIndex = cellIndex(lat, -90, 180, _latitudeUnitCount);
  final shiftedLongitude = lon + Frac.of(180);
  final longitudeTurns = (shiftedLongitude / Frac.of(360)).floor();
  final wrappedLongitude =
      shiftedLongitude - Frac(BigInt.from(360) * longitudeTurns) - Frac.of(180);
  final longitudeIndex = cellIndex(
    wrappedLongitude,
    -180,
    360,
    _longitudeUnitCount,
  );

  final latitudePairDigits = _baseDigits(latitudeIndex ~/ 3125, 20, 5);
  final longitudePairDigits = _baseDigits(longitudeIndex ~/ 1024, 20, 5);
  final latitudeGridDigits = _baseDigits(latitudeIndex % 3125, 5, 5);
  final longitudeGridDigits = _baseDigits(longitudeIndex % 1024, 4, 5);
  final digits = StringBuffer();

  for (var index = 0; index < 5; index++) {
    digits.writeCharCode(_alphabet.codeUnitAt(latitudePairDigits[index]));
    digits.writeCharCode(_alphabet.codeUnitAt(longitudePairDigits[index]));
  }
  for (var index = 0; index < 5; index++) {
    final gridIndex =
        latitudeGridDigits[index] * 4 + longitudeGridDigits[index];
    digits.writeCharCode(_alphabet.codeUnitAt(gridIndex));
  }

  final selectedDigits = digits.toString().substring(0, length);
  final paddedDigits = selectedDigits.padRight(8, '0');
  final prefix = paddedDigits.substring(0, 8);
  final suffix = paddedDigits.length > 8 ? paddedDigits.substring(8) : '';
  return '$prefix+$suffix';
}

Decoded decodeOlc(String code) {
  final separator = code.indexOf('+');
  if (separator != 8 || code.lastIndexOf('+') != separator) {
    throw Failure(1, '$code is not an Open Location Code');
  }

  final suffixLength = code.length - 9;
  if (suffixLength != 0 && (suffixLength < 2 || suffixLength > 7)) {
    throw Failure(1, '$code is not an Open Location Code');
  }

  var prefixLength = 8;
  while (prefixLength > 0 && code.codeUnitAt(prefixLength - 1) == 0x30) {
    prefixLength--;
  }
  final hasPadding = prefixLength < 8;
  if (prefixLength == 0 ||
      prefixLength.isOdd ||
      (hasPadding && suffixLength > 0)) {
    throw Failure(1, '$code is not an Open Location Code');
  }

  final inputDigits = <int>[];
  for (var index = 0; index < prefixLength; index++) {
    inputDigits.add(code.codeUnitAt(index));
  }
  for (var index = 9; index < code.length; index++) {
    inputDigits.add(code.codeUnitAt(index));
  }
  if (inputDigits.isEmpty ||
      inputDigits.any((unit) => !_isAlphabetUnit(unit))) {
    throw Failure(1, '$code is not an Open Location Code');
  }

  final canonicalDigits = asciiUpper(String.fromCharCodes(inputDigits));
  final canonicalUnits = canonicalDigits.codeUnits;
  final pairDigitCount = canonicalUnits.length < 10
      ? canonicalUnits.length
      : 10;
  var latitudeLo = Frac.of(-90);
  var longitudeLo = Frac.of(-180);
  var latitudeStep = Frac.of(20);
  var longitudeStep = Frac.of(20);
  var latitudeCellSize = Frac.of(20);
  var longitudeCellSize = Frac.of(20);

  for (var index = 0; index < pairDigitCount; index += 2) {
    latitudeCellSize = latitudeStep;
    longitudeCellSize = longitudeStep;
    final latitudeDigit = _alphabet.indexOf(
      String.fromCharCode(canonicalUnits[index]),
    );
    final longitudeDigit = _alphabet.indexOf(
      String.fromCharCode(canonicalUnits[index + 1]),
    );
    latitudeLo = latitudeLo + latitudeStep * Frac.of(latitudeDigit);
    longitudeLo = longitudeLo + longitudeStep * Frac.of(longitudeDigit);
    latitudeStep = latitudeStep / Frac.of(20);
    longitudeStep = longitudeStep / Frac.of(20);
  }

  for (var index = 10; index < canonicalUnits.length; index++) {
    final gridIndex = _alphabet.indexOf(
      String.fromCharCode(canonicalUnits[index]),
    );
    final row = gridIndex ~/ 4;
    final column = gridIndex % 4;
    latitudeCellSize = latitudeCellSize / Frac.of(5);
    longitudeCellSize = longitudeCellSize / Frac.of(4);
    latitudeLo = latitudeLo + latitudeCellSize * Frac.of(row);
    longitudeLo = longitudeLo + longitudeCellSize * Frac.of(column);
  }

  final cell = Cell(
    latitudeLo,
    latitudeLo + latitudeCellSize,
    longitudeLo,
    longitudeLo + longitudeCellSize,
  );
  return Decoded(cell, asciiUpper(code));
}

List<int> _baseDigits(int value, int radix, int width) {
  final digits = List<int>.filled(width, 0);
  var remainder = value;
  for (var index = width - 1; index >= 0; index--) {
    digits[index] = remainder % radix;
    remainder ~/= radix;
  }
  return digits;
}

bool _isAlphabetUnit(int unit) {
  return _alphabet.codeUnits.any(
    (alphabetUnit) =>
        alphabetUnit == unit ||
        (unit >= 0x61 && unit <= 0x7a && alphabetUnit == unit - 0x20),
  );
}
