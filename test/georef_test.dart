import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/codec/georef.dart';
import 'package:latcell/src/codec/olc.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('encodes the supplied GEOREF precisions and boundaries', () {
    expect(
      encodeGeoref(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 8),
      equals('DJNH3446'),
    );
    expect(
      encodeGeoref(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 2),
      equals('DJ'),
    );
    expect(
      encodeGeoref(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 4),
      equals('DJNH'),
    );
    expect(
      encodeGeoref(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 10),
      equals('DJNH348464'),
    );
    expect(
      encodeGeoref(Frac.of(377749, 10000), Frac.of(-1224194, 10000), 12),
      equals('DJNH34834649'),
    );
    expect(encodeGeoref(Frac.of(0), Frac.of(0), 8), equals('NGAA0000'));
    expect(encodeGeoref(Frac.of(90), Frac.of(180), 8), equals('ZMQQ5959'));
    expect(encodeGeoref(Frac.of(-90), Frac.of(-180), 8), equals('AAAA0000'));
  });

  test('encodes shared edges and minute boundaries', () {
    expect(encodeGeoref(Frac.of(1, 60), Frac.of(1, 60), 8), equals('NGAA0101'));
    expect(
      encodeGeoref(Frac.of(-1, 60), Frac.of(-1, 60), 8),
      equals('MFQQ5959'),
    );
    expect(encodeGeoref(Frac.of(90), Frac.of(180), 2), equals('ZM'));
  });

  test('decodes the supplied GEOREF examples', () {
    final field = decodeGeoref('MK');
    expect(
      <String>[
        field.code,
        field.cell.latLo.toFixed(7),
        field.cell.latHi.toFixed(7),
        field.cell.lonLo.toFixed(7),
        field.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'MK',
        '45.0000000',
        '60.0000000',
        '-15.0000000',
        '0.0000000',
      ]),
    );
    final degree = decodeGeoref('MKPG');
    expect(
      <String>[
        degree.code,
        degree.cell.latLo.toFixed(7),
        degree.cell.latHi.toFixed(7),
        degree.cell.lonLo.toFixed(7),
        degree.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'MKPG',
        '51.0000000',
        '52.0000000',
        '-2.0000000',
        '-1.0000000',
      ]),
    );
    final lowercase = decodeGeoref('mkpg');
    expect(
      <String>[
        lowercase.code,
        lowercase.cell.latLo.toFixed(7),
        lowercase.cell.latHi.toFixed(7),
        lowercase.cell.lonLo.toFixed(7),
        lowercase.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'MKPG',
        '51.0000000',
        '52.0000000',
        '-2.0000000',
        '-1.0000000',
      ]),
    );
    final minutes = decodeGeoref('DJNH3446');
    expect(
      <String>[
        minutes.code,
        minutes.cell.latLo.toFixed(7),
        minutes.cell.latHi.toFixed(7),
        minutes.cell.lonLo.toFixed(7),
        minutes.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'DJNH3446',
        '37.7666667',
        '37.7833333',
        '-122.4333333',
        '-122.4166667',
      ]),
    );
    final tenths = decodeGeoref('DJNH344578');
    expect(
      <String>[
        tenths.code,
        tenths.cell.latLo.toFixed(7),
        tenths.cell.latHi.toFixed(7),
        tenths.cell.lonLo.toFixed(7),
        tenths.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'DJNH344578',
        '37.9633333',
        '37.9650000',
        '-122.4266667',
        '-122.4250000',
      ]),
    );
    final hundredths = decodeGeoref('DJNH34455678');
    expect(
      <String>[
        hundredths.code,
        hundredths.cell.latLo.toFixed(7),
        hundredths.cell.latHi.toFixed(7),
        hundredths.cell.lonLo.toFixed(7),
        hundredths.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'DJNH34455678',
        '37.9463333',
        '37.9465000',
        '-122.4258333',
        '-122.4256667',
      ]),
    );
    final lower = decodeGeoref('AAAA0000');
    expect(
      <String>[
        lower.code,
        lower.cell.latLo.toFixed(7),
        lower.cell.latHi.toFixed(7),
        lower.cell.lonLo.toFixed(7),
        lower.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'AAAA0000',
        '-90.0000000',
        '-89.9833333',
        '-180.0000000',
        '-179.9833333',
      ]),
    );
    final upper = decodeGeoref('ZMQQ5959');
    expect(
      <String>[
        upper.code,
        upper.cell.latLo.toFixed(7),
        upper.cell.latHi.toFixed(7),
        upper.cell.lonLo.toFixed(7),
        upper.cell.lonHi.toFixed(7),
      ],
      equals(<String>[
        'ZMQQ5959',
        '89.9833333',
        '90.0000000',
        '179.9833333',
        '180.0000000',
      ]),
    );
  });

  test('decodes field, degree, and minute-grid boundaries', () {
    final field = decodeGeoref('NG');
    expect(<String>[
      field.cell.latLo.toFixed(7),
      field.cell.latHi.toFixed(7),
      field.cell.lonLo.toFixed(7),
      field.cell.lonHi.toFixed(7),
    ], equals(<String>['0.0000000', '15.0000000', '0.0000000', '15.0000000']));
    final degree = decodeGeoref('NGAA');
    expect(<String>[
      degree.cell.latLo.toFixed(7),
      degree.cell.latHi.toFixed(7),
      degree.cell.lonLo.toFixed(7),
      degree.cell.lonHi.toFixed(7),
    ], equals(<String>['0.0000000', '1.0000000', '0.0000000', '1.0000000']));
    final minutes = decodeGeoref('NGAA0101');
    expect(<String>[
      minutes.cell.latLo.toFixed(7),
      minutes.cell.latHi.toFixed(7),
      minutes.cell.lonLo.toFixed(7),
      minutes.cell.lonHi.toFixed(7),
    ], equals(<String>['0.0166667', '0.0333333', '0.0166667', '0.0333333']));
    final tenths = decodeGeoref('NGAA001000');
    expect(<String>[
      tenths.cell.latLo.toFixed(7),
      tenths.cell.latHi.toFixed(7),
      tenths.cell.lonLo.toFixed(7),
      tenths.cell.lonHi.toFixed(7),
    ], equals(<String>['0.0000000', '0.0016667', '0.0016667', '0.0033333']));
    final hundredths = decodeGeoref('NGAA00010000');
    expect(<String>[
      hundredths.cell.latLo.toFixed(7),
      hundredths.cell.latHi.toFixed(7),
      hundredths.cell.lonLo.toFixed(7),
      hundredths.cell.lonHi.toFixed(7),
    ], equals(<String>['0.0000000', '0.0001667', '0.0001667', '0.0003333']));
  });

  test('preserves exact rational GEOREF cell bounds and widths', () {
    final southwest = decodeGeoref('AAAA0000');
    expect(
      <Frac>[
        southwest.cell.latLo,
        southwest.cell.latHi,
        southwest.cell.lonLo,
        southwest.cell.lonHi,
      ],
      equals(<Frac>[
        Frac.of(-90),
        Frac.of(-5399, 60),
        Frac.of(-180),
        Frac.of(-10799, 60),
      ]),
    );
    final minutes = decodeGeoref('NGAA0101');
    expect(
      <Frac>[
        minutes.cell.latLo,
        minutes.cell.latHi,
        minutes.cell.lonLo,
        minutes.cell.lonHi,
      ],
      equals(<Frac>[
        Frac.of(1, 60),
        Frac.of(1, 30),
        Frac.of(1, 60),
        Frac.of(1, 30),
      ]),
    );
    final minuteWidths = decodeGeoref('NGAA0000');
    expect(<Frac>[
      minuteWidths.cell.latHi - minuteWidths.cell.latLo,
      minuteWidths.cell.lonHi - minuteWidths.cell.lonLo,
    ], equals(<Frac>[Frac.of(1, 60), Frac.of(1, 60)]));
    final tenthWidths = decodeGeoref('NGAA000000');
    expect(<Frac>[
      tenthWidths.cell.latHi - tenthWidths.cell.latLo,
      tenthWidths.cell.lonHi - tenthWidths.cell.lonLo,
    ], equals(<Frac>[Frac.of(1, 600), Frac.of(1, 600)]));
    final hundredthWidths = decodeGeoref('NGAA00000000');
    expect(<Frac>[
      hundredthWidths.cell.latHi - hundredthWidths.cell.latLo,
      hundredthWidths.cell.lonHi - hundredthWidths.cell.lonLo,
    ], equals(<Frac>[Frac.of(1, 6000), Frac.of(1, 6000)]));
    final upper = decodeGeoref('ZMQQ5959');
    expect(
      <Frac>[
        upper.cell.latHi,
        upper.cell.lonHi,
        upper.cell.centerLat,
        upper.cell.centerLon,
      ],
      equals(<Frac>[
        Frac.of(90),
        Frac.of(180),
        Frac.of(10799, 120),
        Frac.of(21599, 120),
      ]),
    );
  });

  test('checks shared Open Location Code exact examples', () {
    expect(
      encodeOlc(Frac.of(374220, 10000), Frac.of(-1220841, 10000), 12),
      equals('849VCWC8+R925'),
    );
    final grid = decodeOlc('849VCWC8+R9GF');
    expect(<Frac>[
      grid.cell.latHi - grid.cell.latLo,
      grid.cell.lonHi - grid.cell.lonLo,
    ], equals(<Frac>[Frac.of(1, 200000), Frac.of(1, 128000)]));
  });

  test('rejects the supplied invalid lengths, letters, and minute groups', () {
    expect(
      () => decodeGeoref(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              ' is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('M'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'M is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('MKP'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'MKP is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('IK'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'IK is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('MI'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'MI is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('MKPI'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'MKPI is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH34'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH34 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH3460'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH3460 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH346A'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH346A is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH344'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH344 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH600000'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH600000 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH00006000'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH00006000 is not a GEOREF code',
            ),
      ),
    );
  });

  test('rejects excluded and non-ASCII positional characters', () {
    expect(
      () => decodeGeoref('AO'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'AO is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNI0000'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNI0000 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH34６6'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH34６6 is not a GEOREF code',
            ),
      ),
    );
    expect(
      () => decodeGeoref('DJNH345٦'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'DJNH345٦ is not a GEOREF code',
            ),
      ),
    );
  });
}
