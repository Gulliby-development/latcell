import '../base/failure.dart';
import '../base/options.dart';
import '../cell/cell.dart';
import '../num/frac.dart';
import 'geohash.dart';
import 'georef.dart';
import 'maidenhead.dart';
import 'olc.dart';

const List<String> systemNames = <String>[
  'geohash',
  'maidenhead',
  'olc',
  'georef',
];

final RegExp _maidenheadShape = RegExp(
  r'[A-R]{2}([0-9]{2}([a-x]{2}([0-9]{2}([a-x]{2})?)?)?)?',
);
final RegExp _georefShape = RegExp(
  r'[A-HJ-NP-Z][A-HJ-M]([A-HJ-NP-Q]{2}([0-9]{8}|[0-9]{6}|[0-9]{4})?)?',
);
final RegExp _geohashShape = RegExp(r'[0-9b-hjkmnp-z]{1,12}');

int defaultLength(String system) => switch (system) {
  'geohash' => 9,
  'maidenhead' => 6,
  'olc' => 10,
  'georef' => 8,
  _ => throw Failure(2, 'unknown system $system'),
};

void checkLength(String system, int length) {
  final valid = switch (system) {
    'geohash' => length >= 1 && length <= 12,
    'maidenhead' => const <int>{2, 4, 6, 8, 10}.contains(length),
    'olc' => const <int>{2, 4, 6, 8, 10, 11, 12, 13, 14, 15}.contains(length),
    'georef' => const <int>{2, 4, 8, 10, 12}.contains(length),
    _ => throw Failure(2, 'unknown system $system'),
  };
  if (valid) {
    return;
  }

  final allowed = switch (system) {
    'geohash' => '1..12',
    'maidenhead' => '2, 4, 6, 8, 10',
    'olc' => '2, 4, 6, 8, 10, 11, 12, 13, 14, 15',
    'georef' => '2, 4, 8, 10, 12',
    _ => throw Failure(2, 'unknown system $system'),
  };
  throw Failure(1, 'length $length is not valid for $system ($allowed)');
}

String encodeIn(String system, Frac lat, Frac lon, int length) {
  checkLength(system, length);
  return switch (system) {
    'geohash' => encodeGeohash(lat, lon, length),
    'maidenhead' => encodeMaidenhead(lat, lon, length),
    'olc' => encodeOlc(lat, lon, length),
    'georef' => encodeGeoref(lat, lon, length),
    _ => throw Failure(2, 'unknown system $system'),
  };
}

String detectSystem(String code) {
  if (code.contains('+')) {
    return 'olc';
  }
  if (_matchesWhole(_maidenheadShape, code)) {
    return 'maidenhead';
  }
  if (_matchesWhole(_georefShape, code)) {
    return 'georef';
  }
  if (_matchesWhole(_geohashShape, code)) {
    return 'geohash';
  }
  throw Failure(1, 'cannot tell the system of $code; use --system');
}

class Located {
  const Located(this.system, this.decoded);

  final String system;
  final Decoded decoded;
}

Located decodeIn(String code, String? system) {
  final selectedSystem = system ?? detectSystem(code);
  final decoded = switch (selectedSystem) {
    'geohash' => decodeGeohash(code),
    'maidenhead' => decodeMaidenhead(code),
    'olc' => decodeOlc(code),
    'georef' => decodeGeoref(code),
    _ => throw Failure(2, 'unknown system $selectedSystem'),
  };
  return Located(selectedSystem, decoded);
}

String? systemOption(Parsed parsed, String name) {
  final system = parsed.options[name];
  if (system == null) {
    return null;
  }
  if (!systemNames.contains(system)) {
    throw Failure(2, 'unknown system $system');
  }
  return system;
}

bool _matchesWhole(RegExp expression, String code) {
  final match = expression.matchAsPrefix(code);
  return match != null && match.end == code.length;
}
