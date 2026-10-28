import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/codec/olc.dart';
import 'package:latcell/src/num/decimal.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('encodes supported pair and grid precisions', () {
    expect(
      encodeOlc(
        parseDecimal('37.4220', 'latitude', -90, 90),
        parseDecimal('-122.0841', 'longitude', -180, 180),
        10,
      ),
      equals('849VCWC8+R9'),
    );
    expect(
      encodeOlc(
        parseDecimal('37.4220', 'latitude', -90, 90),
        parseDecimal('-122.0841', 'longitude', -180, 180),
        11,
      ),
      equals('849VCWC8+R92'),
    );
    expect(
      encodeOlc(
        parseDecimal('37.4220', 'latitude', -90, 90),
        parseDecimal('-122.0841', 'longitude', -180, 180),
        15,
      ),
      equals('849VCWC8+R925252'),
    );
    expect(
      encodeOlc(
        parseDecimal('37.4220', 'latitude', -90, 90),
        parseDecimal('-122.0841', 'longitude', -180, 180),
        2,
      ),
      equals('84000000+'),
    );
    expect(
      encodeOlc(
        parseDecimal('37.4220', 'latitude', -90, 90),
        parseDecimal('-122.0841', 'longitude', -180, 180),
        6,
      ),
      equals('849VCW00+'),
    );
    expect(encodeOlc(Frac.of(0), Frac.of(0), 10), equals('6FG22222+22'));
    expect(encodeOlc(Frac.of(90), Frac.of(180), 10), equals('C2X2X2X2+X2'));
    expect(encodeOlc(Frac.of(-90), Frac.of(-180), 10), equals('22222222+22'));
    expect(encodeOlc(Frac.of(0), Frac.of(180), 4), equals('62G20000+'));
    expect(
      encodeOlc(Frac.of(374220, 10000), Frac.of(-1220841, 10000), 8),
      equals('849VCWC8+'),
    );
    expect(
      encodeOlc(Frac.of(374220, 10000), Frac.of(-1220841, 10000), 12),
      equals('849VCWC8+R925'),
    );
    expect(
      encodeOlc(Frac.of(374220, 10000), Frac.of(-1220841, 10000), 13),
      equals('849VCWC8+R9252'),
    );
    expect(
      encodeOlc(Frac.of(374220, 10000), Frac.of(-1220841, 10000), 14),
      equals('849VCWC8+R92525'),
    );
  });

  test('decodes supplied pair, padding, and grid examples', () {
    final pair = decodeOlc('849VCWC8+R9');
    expect(
      <String>[
        pair.code,
        pair.cell.latLo.toFixed(7),
        pair.cell.latHi.toFixed(7),
        pair.cell.lonLo.toFixed(7),
        pair.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '849VCWC8+R9',
        '37.4220000',
        '37.4221250',
        '-122.0841250',
        '-122.0840000',
      ]),
    );
    final lowercase = decodeOlc('849vcwc8+r9');
    expect(
      <String>[
        lowercase.code,
        lowercase.cell.latLo.toFixed(7),
        lowercase.cell.latHi.toFixed(7),
        lowercase.cell.lonLo.toFixed(7),
        lowercase.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '849VCWC8+R9',
        '37.4220000',
        '37.4221250',
        '-122.0841250',
        '-122.0840000',
      ]),
    );
    final noSuffix = decodeOlc('849VCWC8+');
    expect(
      <String>[
        noSuffix.code,
        noSuffix.cell.latLo.toFixed(7),
        noSuffix.cell.latHi.toFixed(7),
        noSuffix.cell.lonLo.toFixed(7),
        noSuffix.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '849VCWC8+',
        '37.4200000',
        '37.4225000',
        '-122.0850000',
        '-122.0825000',
      ]),
    );
    final paddedPair = decodeOlc('849VCW00+');
    expect(
      <String>[
        paddedPair.code,
        paddedPair.cell.latLo.toFixed(7),
        paddedPair.cell.latHi.toFixed(7),
        paddedPair.cell.lonLo.toFixed(7),
        paddedPair.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '849VCW00+',
        '37.4000000',
        '37.4500000',
        '-122.1000000',
        '-122.0500000',
      ]),
    );
    final paddedField = decodeOlc('84000000+');
    expect(
      <String>[
        paddedField.code,
        paddedField.cell.latLo.toFixed(7),
        paddedField.cell.latHi.toFixed(7),
        paddedField.cell.lonLo.toFixed(7),
        paddedField.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '84000000+',
        '30.0000000',
        '50.0000000',
        '-140.0000000',
        '-120.0000000',
      ]),
    );
    final positiveLongitude = decodeOlc('8FVC9G8F+6X');
    expect(
      <String>[
        positiveLongitude.code,
        positiveLongitude.cell.latLo.toFixed(7),
        positiveLongitude.cell.latHi.toFixed(7),
        positiveLongitude.cell.lonLo.toFixed(7),
        positiveLongitude.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '8FVC9G8F+6X',
        '47.3655000',
        '47.3656250',
        '8.5248750',
        '8.5250000',
      ]),
    );
    final grid = decodeOlc('849VCWC8+R9GF');
    expect(
      <String>[
        grid.code,
        grid.cell.latLo.toFixed(7),
        grid.cell.latHi.toFixed(7),
        grid.cell.lonLo.toFixed(7),
        grid.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        '849VCWC8+R9GF',
        '37.4220600',
        '37.4220650',
        '-122.0840547',
        '-122.0840469',
      ]),
    );
  });

  test('accepts supported suffix and padded-prefix boundaries', () {
    expect(decodeOlc('849VCWC8+R925252').code, equals('849VCWC8+R925252'));
    expect(decodeOlc('849vcwc8+r925252').code, equals('849VCWC8+R925252'));
    expect(encodeOlc(Frac.of(48), Frac.of(0), 10), equals('8FW22222+22'));
    expect(decodeOlc('849VCWC8+R9GFH').code, equals('849VCWC8+R9GFH'));
    expect(decodeOlc('849V0000+').code, equals('849V0000+'));
    expect(decodeOlc('22222222+').code, equals('22222222+'));
  });

  test('preserves exact rational cell edges and unequal grid widths', () {
    final grid = decodeOlc('849VCWC8+R9GF');
    expect(grid.cell.latHi - grid.cell.latLo, equals(Frac.of(1, 200000)));
    expect(grid.cell.lonHi - grid.cell.lonLo, equals(Frac.of(1, 128000)));
    final lower = decodeOlc('22222222+');
    expect(
      <Frac>[
        lower.cell.latLo,
        lower.cell.latHi,
        lower.cell.lonLo,
        lower.cell.lonHi,
      ],
      equals(<Frac>[
        Frac.of(-90),
        Frac.of(-35999, 400),
        Frac.of(-180),
        Frac.of(-71999, 400),
      ]),
    );
    final pair = decodeOlc('849VCWC8+');
    expect(pair.cell.latHi - pair.cell.latLo, equals(Frac.of(1, 400)));
  });

  test('rejects invalid syntax with the original spelling', () {
    expect(
      () => decodeOlc(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              ' is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8 is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC+'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC+ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+R'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+R is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCW0C+'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCW0C+ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VC000+R9'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VC000+R9 is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8++'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8++ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('8490CWC8+R9'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '8490CWC8+R9 is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('00000000+'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '00000000+ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCW00+R9'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCW00+R9 is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+R925252X'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+R925252X is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VC+WC8'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VC+WC8 is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+R9+'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+R9+ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+R9!'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+R9! is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+0G'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+0G is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC0+'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC0+ is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('849VCWC8+Ré'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '849VCWC8+Ré is not an Open Location Code',
            ),
      ),
    );
    expect(
      () => decodeOlc('+849VCWC8'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              '+849VCWC8 is not an Open Location Code',
            ),
      ),
    );
  });
}
