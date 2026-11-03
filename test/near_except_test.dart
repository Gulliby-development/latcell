import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

Future<String> run(List<String> args) async {
  final outcome = await runCli(
    args,
    Inputs(stdin: () async => [], file: (_) => null),
  );
  return '${outcome.code}|${outcome.out}|${outcome.err}';
}

void main() {
  const rows = <(String, List<String>, String)>[
    (
      'three directions are left out',
      ['near', 'bpbp', '--except', 'N,NE,NW'],
      '0|E bpbr\nSE bpbq\nS bpbn\nSW zzzy\nW zzzz\n|',
    ),
    (
      'the list order does not matter',
      ['near', 'bpbp', '--except', 'NW,N,NE'],
      '0|E bpbr\nSE bpbq\nS bpbn\nSW zzzy\nW zzzz\n|',
    ),
    (
      'the equals form',
      ['near', 'bpbp', '--except=E'],
      '0|N -\nNE -\nSE bpbq\nS bpbn\nSW zzzy\nW zzzz\nNW -\n|',
    ),
    (
      'the option before the code',
      ['near', '--except', 'N,S,E,W', '9q8y'],
      '0|NE 9q9p\nSE 9q9j\nSW 9q8t\nNW 9q8x\n|',
    ),
    (
      'all eight directions leave nothing',
      ['near', 'bpbp', '--except', 'N,NE,E,SE,S,SW,W,NW'],
      '0||',
    ),
    (
      'only and except cannot be combined',
      ['near', 'bpbp', '--only', 'E', '--except', 'W'],
      '2||latcell: options --only and --except cannot be combined\n',
    ),
    (
      'the order of the two options does not matter',
      ['near', 'bpbp', '--except', 'W', '--only', 'E'],
      '2||latcell: options --only and --except cannot be combined\n',
    ),
    (
      'a lowercase name',
      ['near', 'bpbp', '--except', 'n'],
      '2||latcell: option --except needs directions from N,NE,E,SE,S,SW,W,NW, got n\n',
    ),
    (
      'a repeated direction',
      ['near', 'bpbp', '--except', 'E,E'],
      '2||latcell: option --except lists E twice\n',
    ),
    (
      'a missing value',
      ['near', 'bpbp', '--except'],
      '2||latcell: option --except needs a value\n',
    ),
    (
      'the usage error names both options',
      ['near', '--except', 'N'],
      '2||latcell: usage: latcell near CODE [--only DIRS | --except DIRS]\n',
    ),
    (
      'a bad code is still an input error',
      ['near', 'bpba', '--except', 'N'],
      '1||latcell: bpba is not a geohash\n',
    ),
  ];

  for (final (name, args, expected) in rows) {
    test(name, () async {
      expect(await run(args), equals(expected));
    });
  }
}
