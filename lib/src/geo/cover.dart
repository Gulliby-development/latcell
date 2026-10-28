import '../base/failure.dart';
import '../cell/cell.dart';
import '../codec/geohash.dart';
import '../num/frac.dart';

class Box {
  const Box(this.south, this.west, this.north, this.east);

  final Frac south;
  final Frac west;
  final Frac north;
  final Frac east;
}

List<String> coverBox(Box box, int length, int limit) {
  final lonBits = (5 * length + 1) ~/ 2;
  final latBits = (5 * length) ~/ 2;
  final lonCount = 1 << lonBits;
  final latCount = 1 << latBits;

  final westColumn = cellIndex(box.west, -180, 360, lonCount);
  final eastColumn = cellIndex(box.east, -180, 360, lonCount);
  final northRow = cellIndex(box.north, -90, 180, latCount);
  final southRow = cellIndex(box.south, -90, 180, latCount);
  final crossesAntimeridian = box.west > box.east;

  final rowCount = northRow - southRow + 1;
  final columnCount = crossesAntimeridian
      ? westColumn == eastColumn
            ? lonCount
            : lonCount - westColumn + eastColumn + 1
      : eastColumn - westColumn + 1;
  final count = BigInt.from(rowCount) * BigInt.from(columnCount);
  if (count > BigInt.from(limit)) {
    throw Failure(
      1,
      'box needs $count cells at length $length; the limit is $limit',
    );
  }

  final result = <String>[];
  for (var y = northRow; y >= southRow; y--) {
    if (crossesAntimeridian) {
      for (var x = westColumn; x < lonCount; x++) {
        result.add(joinGeohash(GeohashGrid(x, y, lonBits, latBits)));
      }
      final wrappedEnd = westColumn == eastColumn ? eastColumn - 1 : eastColumn;
      for (var x = 0; x <= wrappedEnd; x++) {
        result.add(joinGeohash(GeohashGrid(x, y, lonBits, latBits)));
      }
    } else {
      for (var x = westColumn; x <= eastColumn; x++) {
        result.add(joinGeohash(GeohashGrid(x, y, lonBits, latBits)));
      }
    }
  }
  return result;
}
