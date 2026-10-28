import '../base/failure.dart';
import '../base/text.dart';
import '../cell/cell.dart';
import '../num/frac.dart';

const String _alphabet = '0123456789bcdefghjkmnpqrstuvwxyz';

class GeohashGrid {
  const GeohashGrid(this.x, this.y, this.lonBits, this.latBits);

  final int x;
  final int y;
  final int lonBits;
  final int latBits;
}

String joinGeohash(GeohashGrid grid) {
  final totalBits = grid.lonBits + grid.latBits;
  final length = totalBits ~/ 5;
  final output = StringBuffer();

  for (var character = 0; character < length; character++) {
    var value = 0;
    for (var bit = 0; bit < 5; bit++) {
      value <<= 1;
      final position = character * 5 + bit;
      if (position.isEven) {
        final longitudeBit = grid.lonBits - 1 - position ~/ 2;
        if (((grid.x >> longitudeBit) & 1) != 0) {
          value |= 1;
        }
      } else {
        final latitudeBit = grid.latBits - 1 - position ~/ 2;
        if (((grid.y >> latitudeBit) & 1) != 0) {
          value |= 1;
        }
      }
    }
    output.write(_alphabet[value]);
  }
  return output.toString();
}

GeohashGrid splitGeohash(String code) {
  final normalized = asciiLower(code);
  if (normalized.isEmpty || normalized.length > 12) {
    throw Failure(1, '$code is not a geohash');
  }

  var x = 0;
  var y = 0;
  final totalBits = normalized.length * 5;
  final lonBits = (totalBits + 1) ~/ 2;
  final latBits = totalBits ~/ 2;

  for (var position = 0; position < totalBits; position++) {
    final character = normalized.codeUnitAt(position ~/ 5);
    final value = _alphabet.indexOf(String.fromCharCode(character));
    if (value < 0) {
      throw Failure(1, '$code is not a geohash');
    }
    final bit = (value >> (4 - position % 5)) & 1;
    if (position.isEven) {
      x = (x << 1) | bit;
    } else {
      y = (y << 1) | bit;
    }
  }

  return GeohashGrid(x, y, lonBits, latBits);
}

String encodeGeohash(Frac lat, Frac lon, int length) {
  if (length < 1 || length > 12) {
    throw Failure(1, 'length $length is not valid for geohash (1..12)');
  }

  final totalBits = length * 5;
  final lonBits = (totalBits + 1) ~/ 2;
  final latBits = totalBits ~/ 2;
  final x = cellIndex(lon, -180, 360, 1 << lonBits);
  final y = cellIndex(lat, -90, 180, 1 << latBits);
  return joinGeohash(GeohashGrid(x, y, lonBits, latBits));
}

Decoded decodeGeohash(String code) {
  final grid = splitGeohash(code);
  final lonCount = 1 << grid.lonBits;
  final latCount = 1 << grid.latBits;
  final lonLo = Frac.of(-180) + Frac.of(grid.x * 360, lonCount);
  final lonHi = Frac.of(-180) + Frac.of((grid.x + 1) * 360, lonCount);
  final latLo = Frac.of(-90) + Frac.of(grid.y * 180, latCount);
  final latHi = Frac.of(-90) + Frac.of((grid.y + 1) * 180, latCount);
  return Decoded(Cell(latLo, latHi, lonLo, lonHi), asciiLower(code));
}

List<(String, String)> geohashNeighbors(String code) {
  final grid = splitGeohash(code);
  final lonCount = 1 << grid.lonBits;
  final latCount = 1 << grid.latBits;
  const directions = <(String, int, int)>[
    ('N', 0, 1),
    ('NE', 1, 1),
    ('E', 1, 0),
    ('SE', 1, -1),
    ('S', 0, -1),
    ('SW', -1, -1),
    ('W', -1, 0),
    ('NW', -1, 1),
  ];

  return [
    for (final (name, dx, dy) in directions)
      (
        name,
        grid.y + dy < 0 || grid.y + dy >= latCount
            ? '-'
            : joinGeohash(
                GeohashGrid(
                  (grid.x + dx + lonCount) % lonCount,
                  grid.y + dy,
                  grid.lonBits,
                  grid.latBits,
                ),
              ),
      ),
  ];
}
