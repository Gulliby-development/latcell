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
    ('one direction', ['near', 'bpbp', '--only', 'E'], '0|E bpbr\n|'),
    (
      'two directions keep the standard order',
      ['near', 'bpbp', '--only', 'W,E'],
      '0|E bpbr\nW zzzz\n|',
    ),
    (
      'all eight directions',
      ['near', 'bpbp', '--only', 'NW,W,SW,S,SE,E,NE,N'],
      '0|N -\nNE -\nE bpbr\nSE bpbq\nS bpbn\nSW zzzy\nW zzzz\nNW -\n|',
    ),
    ('a pole sentinel is kept', ['near', 'bpbp', '--only', 'N'], '0|N -\n|'),
    (
      'the equals form',
      ['near', 'bpbp', '--only=S,SW'],
      '0|S bpbn\nSW zzzy\n|',
    ),
    (
      'the option before the code',
      ['near', '--only', 'NE', 'bpbp'],
      '0|NE -\n|',
    ),
    (
      'a geohash that is not at a pole',
      ['near', '9q8y', '--only', 'N'],
      '0|N 9q8z\n|',
    ),
    (
      'an empty value',
      ['near', 'bpbp', '--only='],
      '2||latcell: option --only needs directions from N,NE,E,SE,S,SW,W,NW, got \n',
    ),
    (
      'a lowercase name',
      ['near', 'bpbp', '--only', 'n'],
      '2||latcell: option --only needs directions from N,NE,E,SE,S,SW,W,NW, got n\n',
    ),
    (
      'a space after a comma',
      ['near', 'bpbp', '--only', 'N, E'],
      '2||latcell: option --only needs directions from N,NE,E,SE,S,SW,W,NW, got N, E\n',
    ),
    (
      'a trailing comma',
      ['near', 'bpbp', '--only', 'N,'],
      '2||latcell: option --only needs directions from N,NE,E,SE,S,SW,W,NW, got N,\n',
    ),
    (
      'a repeated direction',
      ['near', 'bpbp', '--only', 'E,NE,E'],
      '2||latcell: option --only lists E twice\n',
    ),
    (
      'the option given twice',
      ['near', 'bpbp', '--only', 'N', '--only', 'E'],
      '2||latcell: option --only given twice\n',
    ),
    (
      'a missing value',
      ['near', 'bpbp', '--only'],
      '2||latcell: option --only needs a value\n',
    ),
    (
      'the usage error names the option',
      ['near', '--only', 'N'],
      '2||latcell: usage: latcell near CODE [--only DIRS]\n',
    ),
    (
      'a bad direction is reported before a bad code',
      ['near', 'bpba', '--only', 'X'],
      '2||latcell: option --only needs directions from N,NE,E,SE,S,SW,W,NW, got X\n',
    ),
    (
      'a bad code is still an input error',
      ['near', 'bpba', '--only', 'N'],
      '1||latcell: bpba is not a geohash\n',
    ),
  ];

  for (final (name, args, expected) in rows) {
    test(name, () async {
      expect(await run(args), equals(expected));
    });
  }
}
