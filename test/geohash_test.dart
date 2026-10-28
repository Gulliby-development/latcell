import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/codec/geohash.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('encodes literal coordinate and length examples', () {
    expect(
      encodeGeohash(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 9),
      equals('9q8yyk8yt'),
    );
    expect(
      encodeGeohash(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 1),
      equals('9'),
    );
    expect(encodeGeohash(Frac.of(0), Frac.of(0), 5), equals('s0000'));
    expect(
      encodeGeohash(Frac.of(90), Frac.of(180), 12),
      equals('zzzzzzzzzzzz'),
    );
    expect(encodeGeohash(Frac.of(-90), Frac.of(-180), 6), equals('000000'));
    expect(
      encodeGeohash(Frac.of(515007, 10000), Frac.of(-1246, 10000), 8),
      equals('gcpuvpmm'),
    );
    expect(
      encodeGeohash(Frac.of(-338688, 10000), Frac.of(1512093, 10000), 7),
      equals('r3gx2f7'),
    );
    expect(
      encodeGeohash(Frac.of(356586, 10000), Frac.of(1397454, 10000), 4),
      equals('xn76'),
    );
  });

  test('decodes exact cells and canonicalizes uppercase spelling', () {
    final decoded = decodeGeohash('9q8yyk8');
    expect(
      [
        decoded.code,
        decoded.cell.latLo.toFixed(7),
        decoded.cell.latHi.toFixed(7),
        decoded.cell.lonLo.toFixed(7),
        decoded.cell.lonHi.toFixed(7),
      ],
      equals([
        '9q8yyk8',
        '37.7737427',
        '37.7751160',
        '-122.4206543',
        '-122.4192810',
      ]),
    );
    final uppercase = decodeGeohash('9Q8YYK8');
    expect(
      [
        uppercase.code,
        uppercase.cell.latLo.toFixed(7),
        uppercase.cell.latHi.toFixed(7),
        uppercase.cell.lonLo.toFixed(7),
        uppercase.cell.lonHi.toFixed(7),
      ],
      equals([
        '9q8yyk8',
        '37.7737427',
        '37.7751160',
        '-122.4206543',
        '-122.4192810',
      ]),
    );
    final zero = decodeGeohash('s');
    expect([
      zero.cell.latLo.toFixed(7),
      zero.cell.latHi.toFixed(7),
      zero.cell.lonLo.toFixed(7),
      zero.cell.lonHi.toFixed(7),
    ], equals(['0.0000000', '45.0000000', '0.0000000', '45.0000000']));
    final pole = decodeGeohash('zzzzzzzzzzzz');
    expect([
      pole.cell.latLo.toFixed(7),
      pole.cell.latHi.toFixed(7),
      pole.cell.lonLo.toFixed(7),
      pole.cell.lonHi.toFixed(7),
    ], equals(['89.9999998', '90.0000000', '179.9999997', '180.0000000']));
  });

  test('rejects every invalid geohash spelling with the original text', () {
    expect(
      () => splitGeohash(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              ' is not a geohash',
            ),
      ),
    );
    expect(
      () => decodeGeohash('a'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'a is not a geohash',
            ),
      ),
    );
    expect(
      () => splitGeohash('9q8yyk8yt0000'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '9q8yyk8yt0000 is not a geohash',
            ),
      ),
    );
    expect(
      () => decodeGeohash('9q8!'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '9q8! is not a geohash',
            ),
      ),
    );
    expect(
      () => splitGeohash('ilo'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'ilo is not a geohash',
            ),
      ),
    );
  });

  test('splits and joins grid coordinates and bit widths', () {
    final sGrid = splitGeohash('s0000');
    expect([
      sGrid.x,
      sGrid.y,
      sGrid.lonBits,
      sGrid.latBits,
    ], equals([4096, 2048, 13, 12]));
    final evenGrid = splitGeohash('ez');
    expect([
      evenGrid.x,
      evenGrid.y,
      evenGrid.lonBits,
      evenGrid.latBits,
    ], equals([15, 23, 5, 5]));
    expect(joinGeohash(const GeohashGrid(1, 3, 3, 2)), equals('c'));
    expect(joinGeohash(const GeohashGrid(15, 23, 5, 5)), equals('ez'));
  });

  test('returns neighbors in north-to-northwest order', () {
    expect(geohashNeighbors('9q8y')[0], equals(('N', '9q8z')));
    expect(geohashNeighbors('9q8y')[1], equals(('NE', '9q9p')));
    expect(geohashNeighbors('9q8y')[2], equals(('E', '9q9n')));
    expect(geohashNeighbors('9q8y')[3], equals(('SE', '9q9j')));
    expect(geohashNeighbors('9q8y')[4], equals(('S', '9q8v')));
    expect(geohashNeighbors('9q8y')[5], equals(('SW', '9q8t')));
    expect(geohashNeighbors('9q8y')[6], equals(('W', '9q8w')));
    expect(geohashNeighbors('9q8y')[7], equals(('NW', '9q8x')));
  });

  test('uses pole sentinels and wraps columns at the antimeridian', () {
    expect(geohashNeighbors('zzzz')[0], equals(('N', '-')));
    expect(geohashNeighbors('zzzz')[1], equals(('NE', '-')));
    expect(geohashNeighbors('zzzz')[2], equals(('E', 'bpbp')));
    expect(geohashNeighbors('zzzz')[3], equals(('SE', 'bpbn')));
    expect(geohashNeighbors('zzzz')[4], equals(('S', 'zzzy')));
    expect(geohashNeighbors('zzzz')[5], equals(('SW', 'zzzw')));
    expect(geohashNeighbors('zzzz')[6], equals(('W', 'zzzx')));
    expect(geohashNeighbors('zzzz')[7], equals(('NW', '-')));
  });

  test('lists neighbors of the one-character cell at both poles', () {
    expect(geohashNeighbors('b')[0], equals(('N', '-')));
    expect(geohashNeighbors('b')[1], equals(('NE', '-')));
    expect(geohashNeighbors('b')[2], equals(('E', 'c')));
    expect(geohashNeighbors('b')[3], equals(('SE', '9')));
    expect(geohashNeighbors('b')[4], equals(('S', '8')));
    expect(geohashNeighbors('b')[5], equals(('SW', 'x')));
    expect(geohashNeighbors('b')[6], equals(('W', 'z')));
    expect(geohashNeighbors('b')[7], equals(('NW', '-')));
  });

  test('lists neighbors across both poles and the wrapped longitude edge', () {
    expect(geohashNeighbors('bpbp')[0], equals(('N', '-')));
    expect(geohashNeighbors('bpbp')[1], equals(('NE', '-')));
    expect(geohashNeighbors('bpbp')[2], equals(('E', 'bpbr')));
    expect(geohashNeighbors('bpbp')[3], equals(('SE', 'bpbq')));
    expect(geohashNeighbors('bpbp')[4], equals(('S', 'bpbn')));
    expect(geohashNeighbors('bpbp')[5], equals(('SW', 'zzzy')));
    expect(geohashNeighbors('bpbp')[6], equals(('W', 'zzzz')));
    expect(geohashNeighbors('bpbp')[7], equals(('NW', '-')));
  });

  test('preserves exact rational edges and shared-boundary ownership', () {
    final exact = decodeGeohash('s').cell;
    expect([
      exact.latLo,
      exact.latHi,
      exact.lonLo,
      exact.lonHi,
    ], equals([Frac.of(0), Frac.of(45), Frac.of(0), Frac.of(45)]));
    expect(encodeGeohash(Frac.of(0), Frac.of(0), 1), equals('s'));
    expect(encodeGeohash(Frac.of(0), Frac.of(-180), 1), equals('8'));
    expect(encodeGeohash(Frac.of(-90), Frac.of(0), 1), equals('h'));
  });
}
