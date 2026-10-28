import 'package:test/test.dart';

import 'package:latcell/src/cell/cell.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('stores exact cell edges and computes exact centers', () {
    final cell = Cell(
      Frac(BigInt.from(1), BigInt.from(3)),
      Frac(BigInt.from(2), BigInt.from(3)),
      Frac(BigInt.from(-2)),
      Frac(BigInt.from(1)),
    );

    expect([
      cell.latLo,
      cell.latHi,
      cell.lonLo,
      cell.lonHi,
    ], equals([Frac.of(1, 3), Frac.of(2, 3), Frac.of(-2), Frac.of(1)]));
    expect(cell.centerLat.toString(), equals('1/2'));
    expect(cell.centerLon.toString(), equals('-1/2'));
  });

  test('stores decoded cell and canonical code', () {
    final cell = Cell(
      Frac(BigInt.from(1), BigInt.from(3)),
      Frac(BigInt.from(2), BigInt.from(3)),
      Frac(BigInt.from(-2)),
      Frac(BigInt.from(1)),
    );
    final decoded = Decoded(cell, 'ABC');

    expect(identical(decoded.cell, cell), equals(true));
    expect(decoded.code, equals('ABC'));
  });

  test('floors and clamps grid indices at the boundaries', () {
    expect(cellIndex(Frac.of(-90), -90, 180, 4), equals(0));
    expect(cellIndex(Frac.of(-45), -90, 180, 4), equals(1));
    expect(cellIndex(Frac.of(90), -90, 180, 4), equals(3));
    expect(cellIndex(Frac.of(-91), -90, 180, 4), equals(0));
    expect(cellIndex(Frac.of(91), -90, 180, 4), equals(3));
    expect(cellIndex(Frac.of(333, 1000), 0, 1, 3), equals(0));
  });
}
