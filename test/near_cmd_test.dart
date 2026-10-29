import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('formats wrapped neighbors and pole sentinels', () async {
    final bpbp = await runCli([
      'near',
      'bpbp',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${bpbp.code}|${bpbp.out}|${bpbp.err}',
      equals(
        '0|N -\n'
        'NE -\n'
        'E bpbr\n'
        'SE bpbq\n'
        'S bpbn\n'
        'SW zzzy\n'
        'W zzzz\n'
        'NW -\n|',
      ),
    );

    final zzzz = await runCli([
      'near',
      'zzzz',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${zzzz.code}|${zzzz.out}|${zzzz.err}',
      equals(
        '0|N -\n'
        'NE -\n'
        'E bpbp\n'
        'SE bpbn\n'
        'S zzzy\n'
        'SW zzzw\n'
        'W zzzx\n'
        'NW -\n|',
      ),
    );

    final b = await runCli([
      'near',
      'b',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${b.code}|${b.out}|${b.err}',
      equals(
        '0|N -\n'
        'NE -\n'
        'E c\n'
        'SE 9\n'
        'S 8\n'
        'SW x\n'
        'W z\n'
        'NW -\n|',
      ),
    );
  });

  test(
    'formats ordinary neighbors in stable order and accepts ASCII case',
    () async {
      final lowercase = await runCli([
        'near',
        '9q8y',
      ], Inputs(stdin: () async => [], file: (_) => null));
      expect(
        '${lowercase.code}|${lowercase.out}|${lowercase.err}',
        equals(
          '0|N 9q8z\n'
          'NE 9q9p\n'
          'E 9q9n\n'
          'SE 9q9j\n'
          'S 9q8v\n'
          'SW 9q8t\n'
          'W 9q8w\n'
          'NW 9q8x\n|',
        ),
      );

      final uppercase = await runCli([
        'near',
        'BPBP',
      ], Inputs(stdin: () async => [], file: (_) => null));
      expect(
        '${uppercase.code}|${uppercase.out}|${uppercase.err}',
        equals(
          '0|N -\n'
          'NE -\n'
          'E bpbr\n'
          'SE bpbq\n'
          'S bpbn\n'
          'SW zzzy\n'
          'W zzzz\n'
          'NW -\n|',
        ),
      );
    },
  );

  test('retains invalid geohash spelling in diagnostics', () async {
    final invalid = await runCli([
      'near',
      'ilo',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${invalid.code}|${invalid.out}|${invalid.err}',
      equals('1||latcell: ilo is not a geohash\n'),
    );

    final empty = await runCli([
      'near',
      '',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${empty.code}|${empty.out}|${empty.err}',
      equals('1||latcell:  is not a geohash\n'),
    );
  });

  test('requires one code positional and rejects options', () async {
    final missingCode = await runCli([
      'near',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${missingCode.code}|${missingCode.out}|${missingCode.err}',
      equals('2||latcell: usage: latcell near CODE [--only DIRS]\n'),
    );

    final extraCode = await runCli([
      'near',
      '9q8y',
      'extra',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${extraCode.code}|${extraCode.out}|${extraCode.err}',
      equals('2||latcell: usage: latcell near CODE [--only DIRS]\n'),
    );

    final unsupportedOption = await runCli([
      'near',
      '9q8y',
      '--length',
      '4',
    ], Inputs(stdin: () async => [], file: (_) => null));
    expect(
      '${unsupportedOption.code}|${unsupportedOption.out}|'
      '${unsupportedOption.err}',
      equals('2||latcell: unknown option --length\n'),
    );
  });
}
