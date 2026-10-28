import '../base/failure.dart';
import '../base/text.dart';
import '../cell/cell.dart';
import '../num/frac.dart';

const String _longitudeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
const String _latitudeAlphabet = 'ABCDEFGHJKLM';
const String _degreeAlphabet = 'ABCDEFGHJKLMNPQ';
const Set<int> _supportedLengths = <int>{2, 4, 8, 10, 12};

String encodeGeoref(Frac lat, Frac lon, int length) {
  if (length == 2) {
    final longitudeField = cellIndex(lon, -180, 360, 24);
    final latitudeField = cellIndex(lat, -90, 180, 12);
    return String.fromCharCodes(<int>[
      _longitudeAlphabet.codeUnitAt(longitudeField),
      _latitudeAlphabet.codeUnitAt(latitudeField),
    ]);
  }

  if (length == 4) {
    final longitudeDegree = cellIndex(lon, -180, 360, 360);
    final latitudeDegree = cellIndex(lat, -90, 180, 180);
    return String.fromCharCodes(<int>[
      _longitudeAlphabet.codeUnitAt(longitudeDegree ~/ 15),
      _latitudeAlphabet.codeUnitAt(latitudeDegree ~/ 15),
      _degreeAlphabet.codeUnitAt(longitudeDegree % 15),
      _degreeAlphabet.codeUnitAt(latitudeDegree % 15),
    ]);
  }

  final minuteDigits = (length - 4) ~/ 2;
  final subdivisions = 60 * _integerPowerOfTen(minuteDigits - 2);
  final longitudeIndex = cellIndex(lon, -180, 360, 360 * subdivisions);
  final latitudeIndex = cellIndex(lat, -90, 180, 180 * subdivisions);
  final longitudeDegree = longitudeIndex ~/ subdivisions;
  final latitudeDegree = latitudeIndex ~/ subdivisions;
  final longitudeMinute = longitudeIndex % subdivisions;
  final latitudeMinute = latitudeIndex % subdivisions;
  final code = StringBuffer()
    ..writeCharCode(_longitudeAlphabet.codeUnitAt(longitudeDegree ~/ 15))
    ..writeCharCode(_latitudeAlphabet.codeUnitAt(latitudeDegree ~/ 15))
    ..writeCharCode(_degreeAlphabet.codeUnitAt(longitudeDegree % 15))
    ..writeCharCode(_degreeAlphabet.codeUnitAt(latitudeDegree % 15))
    ..write(longitudeMinute.toString().padLeft(minuteDigits, '0'))
    ..write(latitudeMinute.toString().padLeft(minuteDigits, '0'));
  return code.toString();
}

Decoded decodeGeoref(String code) {
  if (!_supportedLengths.contains(code.length)) {
    throw Failure(1, '$code is not a GEOREF code');
  }

  final canonicalCode = asciiUpper(code);
  final codeUnits = canonicalCode.codeUnits;
  for (var index = 0; index < codeUnits.length; index++) {
    final unit = codeUnits[index];
    final isValid = switch (index) {
      0 => _longitudeAlphabet.contains(String.fromCharCode(unit)),
      1 => _latitudeAlphabet.contains(String.fromCharCode(unit)),
      2 || 3 => _degreeAlphabet.contains(String.fromCharCode(unit)),
      _ => unit >= 0x30 && unit <= 0x39,
    };
    if (!isValid) {
      throw Failure(1, '$code is not a GEOREF code');
    }
  }

  final longitudeField = _longitudeAlphabet.indexOf(
    String.fromCharCode(codeUnits[0]),
  );
  final latitudeField = _latitudeAlphabet.indexOf(
    String.fromCharCode(codeUnits[1]),
  );
  var longitudeLo = Frac.of(-180 + longitudeField * 15);
  var longitudeWidth = Frac.of(15);
  var latitudeLo = Frac.of(-90 + latitudeField * 15);
  var latitudeWidth = Frac.of(15);

  if (code.length >= 4) {
    final longitudeDegree = _degreeAlphabet.indexOf(
      String.fromCharCode(codeUnits[2]),
    );
    final latitudeDegree = _degreeAlphabet.indexOf(
      String.fromCharCode(codeUnits[3]),
    );
    longitudeLo += Frac.of(longitudeDegree);
    longitudeWidth = Frac.of(1);
    latitudeLo += Frac.of(latitudeDegree);
    latitudeWidth = Frac.of(1);
  }

  if (code.length >= 8) {
    final minuteDigits = (code.length - 4) ~/ 2;
    final subdivisions = 60 * _integerPowerOfTen(minuteDigits - 2);
    final longitudeMinute = _decimalValue(codeUnits, 4, minuteDigits);
    final latitudeMinute = _decimalValue(
      codeUnits,
      4 + minuteDigits,
      minuteDigits,
    );
    if (longitudeMinute >= subdivisions || latitudeMinute >= subdivisions) {
      throw Failure(1, '$code is not a GEOREF code');
    }
    longitudeLo += Frac.of(longitudeMinute, subdivisions);
    longitudeWidth = Frac.of(1, subdivisions);
    latitudeLo += Frac.of(latitudeMinute, subdivisions);
    latitudeWidth = Frac.of(1, subdivisions);
  }

  return Decoded(
    Cell(
      latitudeLo,
      latitudeLo + latitudeWidth,
      longitudeLo,
      longitudeLo + longitudeWidth,
    ),
    canonicalCode,
  );
}

int _decimalValue(List<int> codeUnits, int start, int length) {
  var value = 0;
  for (var index = start; index < start + length; index++) {
    value = value * 10 + codeUnits[index] - 0x30;
  }
  return value;
}

int _integerPowerOfTen(int exponent) {
  var value = 1;
  for (var index = 0; index < exponent; index++) {
    value *= 10;
  }
  return value;
}
