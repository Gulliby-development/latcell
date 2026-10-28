import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/base/options.dart';
import 'package:latcell/src/codec/systems.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('keeps the registry order and defaults', () {
    expect(systemNames, equals(['geohash', 'maidenhead', 'olc', 'georef']));
    expect([
      defaultLength('geohash'),
      defaultLength('maidenhead'),
      defaultLength('olc'),
      defaultLength('georef'),
    ], equals([9, 6, 10, 8]));
  });

  test('accepts every supported precision including both boundaries', () {
    expect(() {
      checkLength('geohash', 1);
      checkLength('geohash', 12);
      return true;
    }(), equals(true));
    expect(() {
      checkLength('maidenhead', 2);
      checkLength('maidenhead', 4);
      checkLength('maidenhead', 6);
      checkLength('maidenhead', 8);
      checkLength('maidenhead', 10);
      return true;
    }(), equals(true));
    expect(() {
      checkLength('olc', 2);
      checkLength('olc', 4);
      checkLength('olc', 6);
      checkLength('olc', 8);
      checkLength('olc', 10);
      checkLength('olc', 11);
      checkLength('olc', 12);
      checkLength('olc', 13);
      checkLength('olc', 14);
      checkLength('olc', 15);
      return true;
    }(), equals(true));
    expect(() {
      checkLength('georef', 2);
      checkLength('georef', 4);
      checkLength('georef', 8);
      checkLength('georef', 10);
      checkLength('georef', 12);
      return true;
    }(), equals(true));
  });

  test('rejects unsupported precision with exact diagnostics', () {
    expect(
      () => checkLength('geohash', 13),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 13 is not valid for geohash (1..12)',
            ),
      ),
    );
    expect(
      () => checkLength('maidenhead', 3),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 3 is not valid for maidenhead (2, 4, 6, 8, 10)',
            ),
      ),
    );
    expect(
      () => checkLength('olc', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 9 is not valid for olc (2, 4, 6, 8, 10, 11, 12, 13, 14, 15)',
            ),
      ),
    );
    expect(
      () => checkLength('georef', 6),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 6 is not valid for georef (2, 4, 8, 10, 12)',
            ),
      ),
    );
    expect(
      () => checkLength('geohash', 0),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 0 is not valid for geohash (1..12)',
            ),
      ),
    );
    expect(
      () => checkLength('maidenhead', 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 1 is not valid for maidenhead (2, 4, 6, 8, 10)',
            ),
      ),
    );
    expect(
      () => checkLength('maidenhead', 11),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 11 is not valid for maidenhead (2, 4, 6, 8, 10)',
            ),
      ),
    );
    expect(
      () => checkLength('olc', 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 1 is not valid for olc (2, 4, 6, 8, 10, 11, 12, 13, 14, 15)',
            ),
      ),
    );
    expect(
      () => checkLength('olc', 16),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 16 is not valid for olc (2, 4, 6, 8, 10, 11, 12, 13, 14, 15)',
            ),
      ),
    );
    expect(
      () => checkLength('georef', 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 1 is not valid for georef (2, 4, 8, 10, 12)',
            ),
      ),
    );
    expect(
      () => checkLength('georef', 13),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 13 is not valid for georef (2, 4, 8, 10, 12)',
            ),
      ),
    );
  });

  test('rejects invalid precision through encode dispatch', () {
    expect(
      () => encodeIn('geohash', Frac.of(0), Frac.of(0), 13),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 13 is not valid for geohash (1..12)',
            ),
      ),
    );
    expect(
      () => encodeIn('maidenhead', Frac.of(0), Frac.of(0), 3),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 3 is not valid for maidenhead (2, 4, 6, 8, 10)',
            ),
      ),
    );
    expect(
      () => encodeIn('olc', Frac.of(0), Frac.of(0), 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 9 is not valid for olc (2, 4, 6, 8, 10, 11, 12, 13, 14, 15)',
            ),
      ),
    );
    expect(
      () => encodeIn('georef', Frac.of(0), Frac.of(0), 6),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'length 6 is not valid for georef (2, 4, 8, 10, 12)',
            ),
      ),
    );
  });

  test('dispatches encoding and precision boundaries to each codec', () {
    expect(
      encodeIn('geohash', Frac.of(377749, 10000), Frac.of(-1224194, 10000), 9),
      equals('9q8yyk8yt'),
    );
    expect(
      encodeIn(
        'maidenhead',
        Frac.of(377749, 10000),
        Frac.of(-1224194, 10000),
        6,
      ),
      equals('CM87ss'),
    );
    expect(
      encodeIn('olc', Frac.of(374220, 10000), Frac.of(-1220841, 10000), 11),
      equals('849VCWC8+R92'),
    );
    expect(
      encodeIn('georef', Frac.of(377749, 10000), Frac.of(-1224194, 10000), 8),
      equals('DJNH3446'),
    );
    expect(
      [
        encodeIn('geohash', Frac.of(0), Frac.of(0), 1),
        encodeIn('geohash', Frac.of(0), Frac.of(0), 12),
        encodeIn(
          'maidenhead',
          Frac.of(377749, 10000),
          Frac.of(-1224194, 10000),
          2,
        ),
        encodeIn(
          'maidenhead',
          Frac.of(377749, 10000),
          Frac.of(-1224194, 10000),
          10,
        ),
        encodeIn('olc', Frac.of(374220, 10000), Frac.of(-1220841, 10000), 2),
        encodeIn('olc', Frac.of(374220, 10000), Frac.of(-1220841, 10000), 15),
        encodeIn('georef', Frac.of(377749, 10000), Frac.of(-1224194, 10000), 2),
        encodeIn(
          'georef',
          Frac.of(377749, 10000),
          Frac.of(-1224194, 10000),
          12,
        ),
      ],
      equals([
        's',
        's00000000000',
        'CM',
        'CM87ss95qx',
        '84000000+',
        '849VCWC8+R925252',
        'DJ',
        'DJNH34834649',
      ]),
    );
  });

  test('dispatches decoding with canonical codes and exact cell edges', () {
    final geohash = decodeIn('9q8yyk8', 'geohash');
    expect(
      [
        geohash.system,
        geohash.decoded.code,
        geohash.decoded.cell.latLo.toFixed(7),
        geohash.decoded.cell.latHi.toFixed(7),
        geohash.decoded.cell.lonLo.toFixed(7),
        geohash.decoded.cell.lonHi.toFixed(7),
      ],
      equals([
        'geohash',
        '9q8yyk8',
        '37.7737427',
        '37.7751160',
        '-122.4206543',
        '-122.4192810',
      ]),
    );
    final maidenhead = decodeIn('CM87wk', 'maidenhead');
    expect(
      [
        maidenhead.system,
        maidenhead.decoded.code,
        maidenhead.decoded.cell.latLo.toFixed(7),
        maidenhead.decoded.cell.latHi.toFixed(7),
        maidenhead.decoded.cell.lonLo.toFixed(7),
        maidenhead.decoded.cell.lonHi.toFixed(7),
      ],
      equals([
        'maidenhead',
        'CM87wk',
        '37.4166667',
        '37.4583333',
        '-122.1666667',
        '-122.0833333',
      ]),
    );
    final olc = decodeIn('849VCWC8+R9', 'olc');
    expect(
      [
        olc.system,
        olc.decoded.code,
        olc.decoded.cell.latLo.toFixed(7),
        olc.decoded.cell.latHi.toFixed(7),
        olc.decoded.cell.lonLo.toFixed(7),
        olc.decoded.cell.lonHi.toFixed(7),
      ],
      equals([
        'olc',
        '849VCWC8+R9',
        '37.4220000',
        '37.4221250',
        '-122.0841250',
        '-122.0840000',
      ]),
    );
    final georef = decodeIn('DJNH3446', 'georef');
    expect(
      [
        georef.system,
        georef.decoded.code,
        georef.decoded.cell.latLo.toFixed(7),
        georef.decoded.cell.latHi.toFixed(7),
        georef.decoded.cell.lonLo.toFixed(7),
        georef.decoded.cell.lonHi.toFixed(7),
      ],
      equals([
        'georef',
        'DJNH3446',
        '37.7666667',
        '37.7833333',
        '-122.4333333',
        '-122.4166667',
      ]),
    );
  });

  test('detects every supplied spelling and rejects all unknown shapes', () {
    expect(
      [
        detectSystem('9q8yyk8'),
        detectSystem('CM87'),
        detectSystem('CM87wk'),
        detectSystem('MKPG'),
        detectSystem('MK'),
        detectSystem('DJNH3446'),
        detectSystem('DJNH344578'),
        detectSystem('DJNH34455678'),
        detectSystem('849VCWC8+R9'),
        detectSystem('84000000+'),
        detectSystem('cm87wk'),
        detectSystem('ez'),
      ],
      equals([
        'geohash',
        'maidenhead',
        'maidenhead',
        'georef',
        'maidenhead',
        'georef',
        'georef',
        'georef',
        'olc',
        'olc',
        'geohash',
        'geohash',
      ]),
    );
    expect(
      () => detectSystem(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of ; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('AB1'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of AB1; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('9Q8Y'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of 9Q8Y; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('ilo'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of ilo; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('zzzzzzzzzzzzz'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of zzzzzzzzzzzzz; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('cm87wk!'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of cm87wk!; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('MKPGX'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of MKPGX; use --system',
            ),
      ),
    );
  });

  test('keeps automatic and explicit resolution spelling-sensitive', () {
    final automaticMk = decodeIn('MK', null);
    expect([
      automaticMk.system,
      automaticMk.decoded.code,
    ], equals(['maidenhead', 'MK']));
    final explicitMk = decodeIn('MK', 'georef');
    expect([
      explicitMk.system,
      explicitMk.decoded.code,
    ], equals(['georef', 'MK']));
    final automaticMixed = decodeIn('cm87wk', null);
    expect([
      automaticMixed.system,
      automaticMixed.decoded.code,
    ], equals(['geohash', 'cm87wk']));
    final explicitMixed = decodeIn('cm87wk', 'maidenhead');
    expect([
      explicitMixed.system,
      explicitMixed.decoded.code,
    ], equals(['maidenhead', 'CM87wk']));
    expect([
      decodeIn('9Q8YYK8', 'geohash').decoded.code,
      decodeIn('cm87WK', 'maidenhead').decoded.code,
      decodeIn('849vcwc8+r9', 'olc').decoded.code,
      decodeIn('djnh3446', 'georef').decoded.code,
    ], equals(['9q8yyk8', 'CM87wk', '849VCWC8+R9', 'DJNH3446']));
    expect([
      decodeIn('9q8yyk8', null).system,
      decodeIn('CM87', null).system,
      decodeIn('849VCWC8+R9', null).system,
      decodeIn('DJNH3446', null).system,
    ], equals(['geohash', 'maidenhead', 'olc', 'georef']));
  });

  test('preserves codec failures and gives plus signs precedence', () {
    expect(
      () => decodeIn('ilo', 'geohash'),
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
    expect(
      () => decodeIn('CM87zz', 'maidenhead'),
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
      () => decodeIn('849VCWC8++', 'olc'),
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
      () => decodeIn('IK', 'georef'),
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
    expect(detectSystem('not-an-olc+'), equals('olc'));
    expect(
      () => decodeIn('not-an-olc+', null),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'not-an-olc+ is not an Open Location Code',
            ),
      ),
    );
  });

  test('requires full-string matches for trailing characters and newlines', () {
    expect(
      () => detectSystem('9q8yyk8!'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of 9q8yyk8!; use --system',
            ),
      ),
    );
    expect(
      () => detectSystem('CM87\n'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'cannot tell the system of CM87\n; use --system',
            ),
      ),
    );
  });

  test('reports unknown systems and validates system options exactly', () {
    expect(
      () => defaultLength('nope'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system nope',
            ),
      ),
    );
    expect(
      () => checkLength('nope', 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system nope',
            ),
      ),
    );
    expect(
      () => encodeIn('nope', Frac.of(0), Frac.of(0), 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system nope',
            ),
      ),
    );
    expect(
      () => decodeIn('9q8yyk8', 'nope'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system nope',
            ),
      ),
    );
    expect(
      systemOption(const Parsed(<String>[], <String, String>{}), 'system'),
      equals(null),
    );
    expect(
      systemOption(const Parsed(<String>[], <String, String>{}), 'to'),
      equals(null),
    );
    expect(
      [
        systemOption(const Parsed(<String>[], {'system': 'geohash'}), 'system'),
        systemOption(
          const Parsed(<String>[], {'system': 'maidenhead'}),
          'system',
        ),
        systemOption(const Parsed(<String>[], {'system': 'olc'}), 'system'),
        systemOption(const Parsed(<String>[], {'system': 'georef'}), 'system'),
        systemOption(const Parsed(<String>[], {'to': 'geohash'}), 'to'),
        systemOption(const Parsed(<String>[], {'to': 'maidenhead'}), 'to'),
        systemOption(const Parsed(<String>[], {'to': 'olc'}), 'to'),
        systemOption(const Parsed(<String>[], {'to': 'georef'}), 'to'),
      ],
      equals([
        'geohash',
        'maidenhead',
        'olc',
        'georef',
        'geohash',
        'maidenhead',
        'olc',
        'georef',
      ]),
    );
    expect(
      () =>
          systemOption(const Parsed(<String>[], {'system': 'nope'}), 'system'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system nope',
            ),
      ),
    );
    expect(
      () => systemOption(const Parsed(<String>[], {'system': ''}), 'system'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having((failure) => failure.message, 'message', 'unknown system '),
      ),
    );
    expect(
      () => systemOption(const Parsed(<String>[], {'to': 'Geohash'}), 'to'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system Geohash',
            ),
      ),
    );
    expect(
      () => decodeIn('9q8yyk8', 'Geohash'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system Geohash',
            ),
      ),
    );
    expect(
      () => encodeIn('Geohash', Frac.of(0), Frac.of(0), 1),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown system Geohash',
            ),
      ),
    );
  });
}
