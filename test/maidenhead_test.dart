import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/codec/maidenhead.dart';
import 'package:latcell/src/num/decimal.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('encodes every supported precision and supplied locations', () {
    expect(
      encodeMaidenhead(parseLat('37.7749'), parseLon('-122.4194'), 6),
      equals('CM87ss'),
    );
    expect(
      encodeMaidenhead(parseLat('37.7749'), parseLon('-122.4194'), 2),
      equals('CM'),
    );
    expect(
      encodeMaidenhead(parseLat('37.7749'), parseLon('-122.4194'), 4),
      equals('CM87'),
    );
    expect(
      encodeMaidenhead(parseLat('37.7749'), parseLon('-122.4194'), 10),
      equals('CM87ss95qx'),
    );
    expect(
      encodeMaidenhead(parseLat('37.7749'), parseLon('-122.4194'), 8),
      equals('CM87ss95'),
    );
    expect(encodeMaidenhead(Frac.of(0), Frac.of(0), 6), equals('JJ00aa'));
    expect(encodeMaidenhead(Frac.of(90), Frac.of(180), 4), equals('RR99'));
    expect(encodeMaidenhead(Frac.of(-90), Frac.of(-180), 6), equals('AA00aa'));
    expect(
      encodeMaidenhead(parseLat('51.5007'), parseLon('-0.1246'), 6),
      equals('IO91wm'),
    );
  });

  test('encodes shared edges and clamped world boundaries', () {
    expect(encodeMaidenhead(Frac.of(44), Frac.of(44), 2), equals('LN'));
    expect(encodeMaidenhead(Frac.of(-80), Frac.of(-160), 2), equals('BB'));
    expect(
      encodeMaidenhead(Frac.of(90), Frac.of(180), 10),
      equals('RR99xx99xx'),
    );
    expect(
      encodeMaidenhead(Frac.of(-90), Frac.of(-180), 10),
      equals('AA00aa00aa'),
    );
    expect(encodeMaidenhead(Frac.of(0), Frac.of(0), 10), equals('JJ00aa00aa'));
  });

  test('decodes the supplied canonical cells', () {
    final square = decodeMaidenhead('CM87');
    expect(
      (
        square.code,
        square.cell.latLo.toFixed(7),
        square.cell.latHi.toFixed(7),
        square.cell.lonLo.toFixed(7),
        square.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87',
        '37.0000000',
        '38.0000000',
        '-124.0000000',
        '-122.0000000',
      )),
    );

    final subsquare = decodeMaidenhead('CM87wk');
    expect(
      (
        subsquare.code,
        subsquare.cell.latLo.toFixed(7),
        subsquare.cell.latHi.toFixed(7),
        subsquare.cell.lonLo.toFixed(7),
        subsquare.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87wk',
        '37.4166667',
        '37.4583333',
        '-122.1666667',
        '-122.0833333',
      )),
    );

    final mixedCase = decodeMaidenhead('cm87WK');
    expect(
      (
        mixedCase.code,
        mixedCase.cell.latLo.toFixed(7),
        mixedCase.cell.latHi.toFixed(7),
        mixedCase.cell.lonLo.toFixed(7),
        mixedCase.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87wk',
        '37.4166667',
        '37.4583333',
        '-122.1666667',
        '-122.0833333',
      )),
    );

    final sharedEdge = decodeMaidenhead('JJ00aa00aa');
    expect(
      (
        sharedEdge.code,
        sharedEdge.cell.latLo.toFixed(7),
        sharedEdge.cell.latHi.toFixed(7),
        sharedEdge.cell.lonLo.toFixed(7),
        sharedEdge.cell.lonHi.toFixed(7),
      ),
      equals((
        'JJ00aa00aa',
        '0.0000000',
        '0.0001736',
        '0.0000000',
        '0.0003472',
      )),
    );

    final upperBoundary = decodeMaidenhead('RR99xx99xx');
    expect(
      (
        upperBoundary.code,
        upperBoundary.cell.latLo.toFixed(7),
        upperBoundary.cell.latHi.toFixed(7),
        upperBoundary.cell.lonLo.toFixed(7),
        upperBoundary.cell.lonHi.toFixed(7),
      ),
      equals((
        'RR99xx99xx',
        '89.9998264',
        '90.0000000',
        '179.9996528',
        '180.0000000',
      )),
    );

    final lowerBoundary = decodeMaidenhead('AA');
    expect(
      (
        lowerBoundary.code,
        lowerBoundary.cell.latLo.toFixed(7),
        lowerBoundary.cell.latHi.toFixed(7),
        lowerBoundary.cell.lonLo.toFixed(7),
        lowerBoundary.cell.lonHi.toFixed(7),
      ),
      equals((
        'AA',
        '-90.0000000',
        '-80.0000000',
        '-180.0000000',
        '-160.0000000',
      )),
    );

    final negativeLongitude = decodeMaidenhead('IO91wm');
    expect(
      (
        negativeLongitude.code,
        negativeLongitude.cell.latLo.toFixed(7),
        negativeLongitude.cell.latHi.toFixed(7),
        negativeLongitude.cell.lonLo.toFixed(7),
        negativeLongitude.cell.lonHi.toFixed(7),
      ),
      equals((
        'IO91wm',
        '51.5000000',
        '51.5416667',
        '-0.1666667',
        '-0.0833333',
      )),
    );
  });

  test('decodes the field, square, subsquare and extended precisions', () {
    final field = decodeMaidenhead('CM');
    expect(
      (
        field.code,
        field.cell.latLo.toFixed(7),
        field.cell.latHi.toFixed(7),
        field.cell.lonLo.toFixed(7),
        field.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM',
        '30.0000000',
        '40.0000000',
        '-140.0000000',
        '-120.0000000',
      )),
    );

    final subsquare = decodeMaidenhead('CM87ss');
    expect(
      (
        subsquare.code,
        subsquare.cell.latLo.toFixed(7),
        subsquare.cell.latHi.toFixed(7),
        subsquare.cell.lonLo.toFixed(7),
        subsquare.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87ss',
        '37.7500000',
        '37.7916667',
        '-122.5000000',
        '-122.4166667',
      )),
    );

    final extended = decodeMaidenhead('CM87ss95');
    expect(
      (
        extended.code,
        extended.cell.latLo.toFixed(7),
        extended.cell.latHi.toFixed(7),
        extended.cell.lonLo.toFixed(7),
        extended.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87ss95',
        '37.7708333',
        '37.7750000',
        '-122.4250000',
        '-122.4166667',
      )),
    );

    final lowercase = decodeMaidenhead('cm87SS95QX');
    expect(
      (
        lowercase.code,
        lowercase.cell.latLo.toFixed(7),
        lowercase.cell.latHi.toFixed(7),
        lowercase.cell.lonLo.toFixed(7),
        lowercase.cell.lonHi.toFixed(7),
      ),
      equals((
        'CM87ss95qx',
        '37.7748264',
        '37.7750000',
        '-122.4194444',
        '-122.4190972',
      )),
    );
  });

  test('rejects every supplied invalid code with its original spelling', () {
    expect(
      () => decodeMaidenhead(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              ' is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('C'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'C is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM8'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM8 is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('SS'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'SS is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CMA7'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CMA7 is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87zz'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87zz is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87wk9'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87wk9 is not a Maidenhead locator',
            ),
      ),
    );
  });

  test('rejects invalid characters in each Maidenhead position', () {
    expect(
      () => decodeMaidenhead('SM'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'SM is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('AS'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'AS is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87w!'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87w! is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87wk-5'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87wk-5 is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87wk95qz'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87wk95qz is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87wk95qx0'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87wk95qx0 is not a Maidenhead locator',
            ),
      ),
    );
    expect(
      () => decodeMaidenhead('CM87w\u00e9'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'CM87w\u00e9 is not a Maidenhead locator',
            ),
      ),
    );
  });

  test('retains exact rational bounds at each precision', () {
    final field = decodeMaidenhead('AA').cell;
    expect((
      field.latLo,
      field.latHi,
      field.lonLo,
      field.lonHi,
    ), equals((Frac.of(-90), Frac.of(-80), Frac.of(-180), Frac.of(-160))));

    final square = decodeMaidenhead('CM87').cell;
    expect((
      square.latLo,
      square.latHi,
      square.lonLo,
      square.lonHi,
    ), equals((Frac.of(37), Frac.of(38), Frac.of(-124), Frac.of(-122))));

    final subsquare = decodeMaidenhead('CM87ss').cell;
    expect(
      (subsquare.latLo, subsquare.latHi, subsquare.lonLo, subsquare.lonHi),
      equals((
        Frac.of(151, 4),
        Frac.of(907, 24),
        Frac.of(-245, 2),
        Frac.of(-1469, 12),
      )),
    );

    final extended = decodeMaidenhead('CM87ss95').cell;
    expect(
      (extended.latLo, extended.latHi, extended.lonLo, extended.lonHi),
      equals((
        Frac.of(1813, 48),
        Frac.of(1511, 40),
        Frac.of(-4897, 40),
        Frac.of(-1469, 12),
      )),
    );

    final finest = decodeMaidenhead('JJ00aa00aa').cell;
    expect((
      finest.latLo,
      finest.latHi,
      finest.lonLo,
      finest.lonHi,
    ), equals((Frac.of(0), Frac.of(1, 5760), Frac.of(0), Frac.of(1, 2880))));
  });
}
