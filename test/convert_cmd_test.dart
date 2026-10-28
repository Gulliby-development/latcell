import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('uses each target system default length', () async {
    final olcResult = await runCli(
      ['convert', '9q8yyk8', '--to', 'olc'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${olcResult.code}|${olcResult.out}|${olcResult.err}',
      equals('0|849VQHFJ+Q2\n|'),
    );

    final geohashResult = await runCli(
      ['convert', '9q8yyk8yt', '--to', 'geohash'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${geohashResult.code}|${geohashResult.out}|${geohashResult.err}',
      equals('0|9q8yyk8yt\n|'),
    );

    final maidenheadResult = await runCli(
      ['convert', 'CM87wk', '--to', 'maidenhead'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${maidenheadResult.code}|${maidenheadResult.out}|${maidenheadResult.err}',
      equals('0|CM87wk\n|'),
    );

    final georefResult = await runCli(
      ['convert', 'DJNH3446', '--to', 'georef'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${georefResult.code}|${georefResult.out}|${georefResult.err}',
      equals('0|DJNH3446\n|'),
    );
  });

  test('uses an explicit target precision', () async {
    final result = await runCli(
      ['convert', '849VCWC8+R9', '--to', 'georef', '--length', '4'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect('${result.code}|${result.out}|${result.err}', equals('0|DJNH\n|'));
  });

  test('requires a target system', () async {
    final result = await runCli(
      ['convert', '9q8yyk8'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: option --to is required\n'),
    );
  });

  test('decodes before checking target precision', () async {
    final result = await runCli(
      ['convert', 'AB1', '--to', 'geohash', '--length', '13'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('1||latcell: cannot tell the system of AB1; use --system\n'),
    );
  });

  test('rejects an unknown target system', () async {
    final result = await runCli(
      ['convert', '9q8yyk8', '--to', 'nope'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: unknown system nope\n'),
    );
  });

  test('honors an explicit source system and target precision', () async {
    final result = await runCli(
      [
        'convert',
        '9q8yyk8yt',
        '--system',
        'geohash',
        '--to',
        'georef',
        '--length',
        '4',
      ],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect('${result.code}|${result.out}|${result.err}', equals('0|DJNH\n|'));
  });

  test('rejects an unknown source system', () async {
    final result = await runCli(
      ['convert', '9q8yyk8', '--to', 'geohash', '--system', 'nope'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: unknown system nope\n'),
    );
  });

  test('rejects an invalid target length', () async {
    final result = await runCli(
      ['convert', '9q8yyk8yt', '--to', 'geohash', '--length', '13'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('1||latcell: length 13 is not valid for geohash (1..12)\n'),
    );
  });

  test('decodes before parsing a malformed target length', () async {
    final result = await runCli(
      ['convert', 'AB1', '--to', 'geohash', '--length', 'x'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('1||latcell: cannot tell the system of AB1; use --system\n'),
    );
  });

  test('rejects a missing code positional', () async {
    final result = await runCli(
      ['convert', '--to', 'geohash'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals(
        '2||latcell: usage: latcell convert CODE --to SYSTEM '
        '[--length N] [--system SYSTEM]\n',
      ),
    );
  });

  test('accepts the maximum Open Location Code target length', () async {
    final result = await runCli(
      ['convert', '9q8yyk8', '--to', 'olc', '--length', '15'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('0|849VQHFJ+Q2F2R8M\n|'),
    );
  });

  test('rejects undocumented options', () async {
    final result = await runCli(
      ['convert', '9q8yyk8', '--to', 'geohash', '--x', '1'],
      Inputs(
        stdin: () async => [],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: unknown option --x\n'),
    );
  });
}
