import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('formats detected geohash, OLC, Maidenhead, and GEOREF cells', () async {
    final geohash = await runCli([
      'decode',
      '9q8yyk8',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${geohash.code}|${geohash.out}|${geohash.err}',
      equals(
        '0|system: geohash\n'
        'code: 9q8yyk8\n'
        'lat: 37.7737427 .. 37.7751160\n'
        'lon: -122.4206543 .. -122.4192810\n'
        'center: 37.7744293, -122.4199677\n|',
      ),
    );

    final olc = await runCli([
      'decode',
      '849VCWC8+R9',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${olc.code}|${olc.out}|${olc.err}',
      equals(
        '0|system: olc\n'
        'code: 849VCWC8+R9\n'
        'lat: 37.4220000 .. 37.4221250\n'
        'lon: -122.0841250 .. -122.0840000\n'
        'center: 37.4220625, -122.0840625\n|',
      ),
    );

    final maidenhead = await runCli([
      'decode',
      'cm87wk',
      '--system',
      'maidenhead',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${maidenhead.code}|${maidenhead.out}|${maidenhead.err}',
      equals(
        '0|system: maidenhead\n'
        'code: CM87wk\n'
        'lat: 37.4166667 .. 37.4583333\n'
        'lon: -122.1666667 .. -122.0833333\n'
        'center: 37.4375000, -122.1250000\n|',
      ),
    );

    final georef = await runCli([
      'decode',
      'MKPG',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${georef.code}|${georef.out}|${georef.err}',
      equals(
        '0|system: georef\n'
        'code: MKPG\n'
        'lat: 51.0000000 .. 52.0000000\n'
        'lon: -2.0000000 .. -1.0000000\n'
        'center: 51.5000000, -1.5000000\n|',
      ),
    );
  });

  test('canonicalizes explicitly selected codes', () async {
    final uppercaseGeohash = await runCli([
      'decode',
      '9Q8YYK8',
      '--system',
      'geohash',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${uppercaseGeohash.code}|${uppercaseGeohash.out}|'
      '${uppercaseGeohash.err}',
      equals(
        '0|system: geohash\n'
        'code: 9q8yyk8\n'
        'lat: 37.7737427 .. 37.7751160\n'
        'lon: -122.4206543 .. -122.4192810\n'
        'center: 37.7744293, -122.4199677\n|',
      ),
    );

    // Explicit Maidenhead canonicalization is covered above.
  });

  test('uses spelling-sensitive detection', () async {
    final mixedCase = await runCli([
      'decode',
      'CM',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${mixedCase.code}|${mixedCase.out}|${mixedCase.err}',
      equals(
        '0|system: maidenhead\n'
        'code: CM\n'
        'lat: 30.0000000 .. 40.0000000\n'
        'lon: -140.0000000 .. -120.0000000\n'
        'center: 35.0000000, -130.0000000\n|',
      ),
    );

    final lowercase = await runCli([
      'decode',
      'cm',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${lowercase.code}|${lowercase.out}|${lowercase.err}',
      equals(
        '0|system: geohash\n'
        'code: cm\n'
        'lat: 73.1250000 .. 78.7500000\n'
        'lon: -123.7500000 .. -112.5000000\n'
        'center: 75.9375000, -118.1250000\n|',
      ),
    );
  });

  test('reports system-detection failures', () async {
    final ambiguous = await runCli([
      'decode',
      'AB1',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${ambiguous.code}|${ambiguous.out}|${ambiguous.err}',
      equals('1||latcell: cannot tell the system of AB1; use --system\n'),
    );

    final uppercaseGeohash = await runCli([
      'decode',
      '9Q8Y',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${uppercaseGeohash.code}|${uppercaseGeohash.out}|'
      '${uppercaseGeohash.err}',
      equals('1||latcell: cannot tell the system of 9Q8Y; use --system\n'),
    );
  });

  test('reports invalid codes for explicit systems', () async {
    final geohash = await runCli([
      'decode',
      'ilo',
      '--system',
      'geohash',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${geohash.code}|${geohash.out}|${geohash.err}',
      equals('1||latcell: ilo is not a geohash\n'),
    );

    final maidenhead = await runCli([
      'decode',
      'CM8',
      '--system',
      'maidenhead',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${maidenhead.code}|${maidenhead.out}|${maidenhead.err}',
      equals('1||latcell: CM8 is not a Maidenhead locator\n'),
    );
  });

  test('validates documented options', () async {
    final unknownSystem = await runCli([
      'decode',
      '9q8yyk8',
      '--system',
      'nope',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${unknownSystem.code}|${unknownSystem.out}|'
      '${unknownSystem.err}',
      equals('2||latcell: unknown system nope\n'),
    );

    final unknownOption = await runCli([
      'decode',
      '9q8yyk8',
      '--length',
      '7',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${unknownOption.code}|${unknownOption.out}|${unknownOption.err}',
      equals('2||latcell: unknown option --length\n'),
    );

    final missingValue = await runCli([
      'decode',
      '9q8yyk8',
      '--system',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${missingValue.code}|${missingValue.out}|${missingValue.err}',
      equals('2||latcell: option --system needs a value\n'),
    );

    final repeatedOption = await runCli([
      'decode',
      '9q8yyk8',
      '--system',
      'geohash',
      '--system',
      'olc',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${repeatedOption.code}|${repeatedOption.out}|'
      '${repeatedOption.err}',
      equals('2||latcell: option --system given twice\n'),
    );
  });

  test('requires exactly one code positional', () async {
    final missingCode = await runCli([
      'decode',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${missingCode.code}|${missingCode.out}|${missingCode.err}',
      equals('2||latcell: usage: latcell decode CODE [--system SYSTEM]\n'),
    );

    final extraCode = await runCli([
      'decode',
      '9q8yyk8',
      'extra',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${extraCode.code}|${extraCode.out}|${extraCode.err}',
      equals('2||latcell: usage: latcell decode CODE [--system SYSTEM]\n'),
    );
  });
}
