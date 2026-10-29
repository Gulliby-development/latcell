import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('shows the literal usage text when no command is supplied', () async {
    final result = await runCli(
      [],
      Inputs(stdin: () async => [], file: (path) => null),
    );

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals(
        '2||usage: latcell COMMAND [ARGS]\n'
        'commands:\n'
        '  encode SYSTEM LAT LON [--length N]\n'
        '  decode CODE [--system SYSTEM]\n'
        '  convert CODE --to SYSTEM [--length N] [--system SYSTEM]\n'
        '  near CODE [--only DIRS]\n'
        '  cover --box S,W,N,E --length N [--limit M]\n'
        '  trail FILE [--system SYSTEM] [--length N]\n'
        'systems: geohash, maidenhead, olc, georef\n',
      ),
    );
  });

  test('prints help for --help', () async {
    final result = await runCli([
      '--help',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals(
        '0|usage: latcell COMMAND [ARGS]\n'
        'commands:\n'
        '  encode SYSTEM LAT LON [--length N]\n'
        '  decode CODE [--system SYSTEM]\n'
        '  convert CODE --to SYSTEM [--length N] [--system SYSTEM]\n'
        '  near CODE [--only DIRS]\n'
        '  cover --box S,W,N,E --length N [--limit M]\n'
        '  trail FILE [--system SYSTEM] [--length N]\n'
        'systems: geohash, maidenhead, olc, georef\n|',
      ),
    );

    final result2 = await runCli([
      'help',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result2.code}|${result2.out}|${result2.err}',
      equals(
        '0|usage: latcell COMMAND [ARGS]\n'
        'commands:\n'
        '  encode SYSTEM LAT LON [--length N]\n'
        '  decode CODE [--system SYSTEM]\n'
        '  convert CODE --to SYSTEM [--length N] [--system SYSTEM]\n'
        '  near CODE [--only DIRS]\n'
        '  cover --box S,W,N,E --length N [--limit M]\n'
        '  trail FILE [--system SYSTEM] [--length N]\n'
        'systems: geohash, maidenhead, olc, georef\n|',
      ),
    );

    final result3 = await runCli([
      'help',
      'extra',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result3.code}|${result3.out}|${result3.err}',
      equals(
        '0|usage: latcell COMMAND [ARGS]\n'
        'commands:\n'
        '  encode SYSTEM LAT LON [--length N]\n'
        '  decode CODE [--system SYSTEM]\n'
        '  convert CODE --to SYSTEM [--length N] [--system SYSTEM]\n'
        '  near CODE [--only DIRS]\n'
        '  cover --box S,W,N,E --length N [--limit M]\n'
        '  trail FILE [--system SYSTEM] [--length N]\n'
        'systems: geohash, maidenhead, olc, georef\n|',
      ),
    );
  });

  test('prints the exact version', () async {
    final result = await runCli([
      '--version',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|latcell 0.1.0\n|'),
    );
  });

  test('prints the version and ignores trailing arguments', () async {
    final result = await runCli([
      '--version',
      'extra',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|latcell 0.1.0\n|'),
    );
  });

  test('reports an unknown command with its status and prefix', () async {
    final result = await runCli([
      'wat',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: unknown command wat\n'),
    );
  });

  test('dispatches encode', () async {
    final result = await runCli([
      'encode',
      'geohash',
      '37.7749',
      '-122.4194',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|9q8yyk8yt\n|'),
    );
  });

  test('dispatches decode', () async {
    final result = await runCli([
      'decode',
      '9q8yyk8',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals(
        '0|system: geohash\n'
        'code: 9q8yyk8\n'
        'lat: 37.7737427 .. 37.7751160\n'
        'lon: -122.4206543 .. -122.4192810\n'
        'center: 37.7744293, -122.4199677\n|',
      ),
    );
  });

  test('dispatches convert', () async {
    final result = await runCli([
      'convert',
      '9q8yyk8',
      '--to',
      'olc',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|849VQHFJ+Q2\n|'),
    );
  });

  test('dispatches near', () async {
    final result = await runCli([
      'near',
      'bpbp',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
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
  });

  test('dispatches cover', () async {
    final result = await runCli([
      'cover',
      '--box',
      '37.77,-122.43,37.78,-122.41',
      '--length',
      '6',
    ], Inputs(stdin: () async => [], file: (path) => null));

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|9q8yyj\n9q8yym\n9q8yyh\n9q8yyk\n9q8yy5\n9q8yy7\n|'),
    );
  });

  test('dispatches trail with a literal empty file input', () async {
    final result = await runCli(
      ['trail', 'empty.csv'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{'empty.csv': []}[path],
      ),
    );

    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|runs: 0 points: 0\n|'),
    );
  });
}
