import '../base/failure.dart';
import '../base/text.dart';
import '../cell/cell.dart';
import '../num/frac.dart';

const String _fieldAlphabet = 'ABCDEFGHIJKLMNOPQR';
const String _subsquareAlphabet = 'abcdefghijklmnopqrstuvwx';
const List<int> _pairRadices = <int>[18, 10, 24, 10, 24];
const Set<int> _supportedLengths = <int>{2, 4, 6, 8, 10};

String encodeMaidenhead(Frac lat, Frac lon, int length) {
  final pairCount = length ~/ 2;
  var total = 1;
  for (var pair = 0; pair < pairCount; pair++) {
    total *= _pairRadices[pair];
  }

  var place = total;
  final longitudeIndex = cellIndex(lon, -180, 360, total);
  final latitudeIndex = cellIndex(lat, -90, 180, total);
  final code = StringBuffer();

  for (var pair = 0; pair < pairCount; pair++) {
    final radix = _pairRadices[pair];
    place ~/= radix;
    final longitudeDigit = (longitudeIndex ~/ place) % radix;
    final latitudeDigit = (latitudeIndex ~/ place) % radix;

    if (pair == 0) {
      code.writeCharCode(_fieldAlphabet.codeUnitAt(longitudeDigit));
      code.writeCharCode(_fieldAlphabet.codeUnitAt(latitudeDigit));
    } else if (pair == 2 || pair == 4) {
      code.writeCharCode(_subsquareAlphabet.codeUnitAt(longitudeDigit));
      code.writeCharCode(_subsquareAlphabet.codeUnitAt(latitudeDigit));
    } else {
      code.writeCharCode(0x30 + longitudeDigit);
      code.writeCharCode(0x30 + latitudeDigit);
    }
  }

  return code.toString();
}

Decoded decodeMaidenhead(String code) {
  if (!_supportedLengths.contains(code.length)) {
    throw Failure(1, '$code is not a Maidenhead locator');
  }

  final codeUnits = code.codeUnits;
  for (var index = 0; index < codeUnits.length; index++) {
    final unit = codeUnits[index];
    final pair = index ~/ 2;
    if (!_isValidCharacter(unit, pair)) {
      throw Failure(1, '$code is not a Maidenhead locator');
    }
  }

  var total = 1;
  var longitudeIndex = 0;
  var latitudeIndex = 0;
  final canonicalCode = StringBuffer();

  for (var pair = 0; pair < codeUnits.length ~/ 2; pair++) {
    final radix = _pairRadices[pair];
    total *= radix;
    final offset = pair * 2;
    final longitudeUnit = codeUnits[offset];
    final latitudeUnit = codeUnits[offset + 1];
    final longitudeDigit = _digitValue(longitudeUnit);
    final latitudeDigit = _digitValue(latitudeUnit);
    longitudeIndex = longitudeIndex * radix + longitudeDigit;
    latitudeIndex = latitudeIndex * radix + latitudeDigit;

    if (pair == 0) {
      canonicalCode.write(asciiUpper(String.fromCharCode(longitudeUnit)));
      canonicalCode.write(asciiUpper(String.fromCharCode(latitudeUnit)));
    } else if (pair == 2 || pair == 4) {
      canonicalCode.write(asciiLower(String.fromCharCode(longitudeUnit)));
      canonicalCode.write(asciiLower(String.fromCharCode(latitudeUnit)));
    } else {
      canonicalCode.writeCharCode(longitudeUnit);
      canonicalCode.writeCharCode(latitudeUnit);
    }
  }

  final cell = Cell(
    Frac.of(-90) + Frac.of(latitudeIndex * 180, total),
    Frac.of(-90) + Frac.of((latitudeIndex + 1) * 180, total),
    Frac.of(-180) + Frac.of(longitudeIndex * 360, total),
    Frac.of(-180) + Frac.of((longitudeIndex + 1) * 360, total),
  );
  return Decoded(cell, canonicalCode.toString());
}

bool _isValidCharacter(int unit, int pair) {
  if (pair == 0) {
    return (unit >= 0x41 && unit <= 0x52) || (unit >= 0x61 && unit <= 0x72);
  }
  if (pair == 2 || pair == 4) {
    return (unit >= 0x41 && unit <= 0x58) || (unit >= 0x61 && unit <= 0x78);
  }
  return unit >= 0x30 && unit <= 0x39;
}

int _digitValue(int unit) {
  if (unit >= 0x61) {
    return unit - 0x61;
  }
  if (unit >= 0x41) {
    return unit - 0x41;
  }
  return unit - 0x30;
}
