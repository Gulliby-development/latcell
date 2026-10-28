import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';
import 'package:test/test.dart';

void main() {
  test('encodes the prescribed defaults and precision options', () async {
    final result1 = await runCli(
      ['encode', 'geohash', '37.7749', '-122.4194'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result1.code}|${result1.out}|${result1.err}',
      equals('0|9q8yyk8yt\n|'),
    );

    final result2 = await runCli(
      ['encode', 'olc', '37.4220', '-122.0841', '--length', '11'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result2.code}|${result2.out}|${result2.err}',
      equals('0|849VCWC8+R92\n|'),
    );

    final result3 = await runCli(
      ['encode', 'maidenhead', '37.7749', '-122.4194'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result3.code}|${result3.out}|${result3.err}',
      equals('0|CM87ss\n|'),
    );

    final result4 = await runCli(
      ['encode', 'georef', '37.7749', '-122.4194'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result4.code}|${result4.out}|${result4.err}',
      equals('0|DJNH3446\n|'),
    );

    final result5 = await runCli(
      ['encode', 'geohash', '0', '0', '--length=5'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result5.code}|${result5.out}|${result5.err}',
      equals('0|s0000\n|'),
    );
  });

  test(
    'preserves system, precision, and coordinate validation precedence',
    () async {
      final result1 = await runCli(
        ['encode', 'nope', '1', '2'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result1.code}|${result1.out}|${result1.err}',
        equals('2||latcell: unknown system nope\n'),
      );

      final result2 = await runCli(
        ['encode', 'geohash', '91', '0'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result2.code}|${result2.out}|${result2.err}',
        equals('1||latcell: latitude 91 is outside -90..90\n'),
      );

      final result3 = await runCli(
        ['encode', 'geohash', '0', '0', '--length', '13'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result3.code}|${result3.out}|${result3.err}',
        equals('1||latcell: length 13 is not valid for geohash (1..12)\n'),
      );

      final result4 = await runCli(
        ['encode', 'nope', '91', '181', '--length', '13'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result4.code}|${result4.out}|${result4.err}',
        equals('2||latcell: unknown system nope\n'),
      );

      final result5 = await runCli(
        ['encode', 'geohash', '91', '181', '--length', '13'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result5.code}|${result5.out}|${result5.err}',
        equals('1||latcell: length 13 is not valid for geohash (1..12)\n'),
      );

      final result6 = await runCli(
        ['encode', 'geohash', '91', '181'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result6.code}|${result6.out}|${result6.err}',
        equals('1||latcell: latitude 91 is outside -90..90\n'),
      );

      final result7 = await runCli(
        ['encode', 'geohash', '0', '181'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result7.code}|${result7.out}|${result7.err}',
        equals('1||latcell: longitude 181 is outside -180..180\n'),
      );

      final result8 = await runCli(
        ['encode', 'geohash', '1e3', '0'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result8.code}|${result8.out}|${result8.err}',
        equals('1||latcell: latitude 1e3 is not a decimal number\n'),
      );

      final result9 = await runCli(
        ['encode', 'maidenhead', '0', '0', '--length', '20'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result9.code}|${result9.out}|${result9.err}',
        equals(
          '1||latcell: length 20 is not valid for maidenhead (2, 4, 6, 8, 10)\n',
        ),
      );
    },
  );

  test(
    'rejects unsupported options, missing values, duplicates, and signed lengths',
    () async {
      final result1 = await runCli(
        ['encode', 'geohash', '0', '0', '--x', '1'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result1.code}|${result1.out}|${result1.err}',
        equals('2||latcell: unknown option --x\n'),
      );

      final result2 = await runCli(
        ['encode', 'geohash', '0', '0', '--length'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result2.code}|${result2.out}|${result2.err}',
        equals('2||latcell: option --length needs a value\n'),
      );

      final result3 = await runCli(
        ['encode', 'geohash', '0', '0', '--length', '5', '--length=6'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result3.code}|${result3.out}|${result3.err}',
        equals('2||latcell: option --length given twice\n'),
      );

      final result4 = await runCli(
        ['encode', 'geohash', '0', '0', '--length=+5'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result4.code}|${result4.out}|${result4.err}',
        equals('2||latcell: option --length needs a whole number, got +5\n'),
      );

      final result5 = await runCli(
        ['encode', 'geohash', '--', '-90', '-180'],
        Inputs(
          stdin: () async => <int>[],
          file: (path) => <String, List<int>>{}[path],
        ),
      );
      expect(
        '${result5.code}|${result5.out}|${result5.err}',
        equals('0|000000000\n|'),
      );
    },
  );

  test('rejects an incorrect positional count with the encode usage', () async {
    final result = await runCli(
      ['encode', 'geohash', '0'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${result.code}|${result.out}|${result.err}',
      equals('2||latcell: usage: latcell encode SYSTEM LAT LON [--length N]\n'),
    );
  });
}
