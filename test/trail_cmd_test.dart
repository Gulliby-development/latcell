import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('formats both prescribed walk.csv runs', () async {
    final defaultLength = await runCli(
      ['trail', 'walk.csv'],
      Inputs(
        stdin: () async => [],
        file: (path) => {
          'walk.csv': [
            32,
            32,
            35,
            32,
            109,
            111,
            114,
            110,
            105,
            110,
            103,
            32,
            119,
            97,
            108,
            107,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            49,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            49,
            10,
            32,
            32,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            57,
            48,
            44,
            32,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            52,
            48,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            57,
            48,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            52,
            49,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            10,
          ],
        }[path],
      ),
    );
    expect(
      '${defaultLength.code}|${defaultLength.out}|${defaultLength.err}',
      equals(
        '0|9q8yyk8yt 1 2 2\n'
        '9q8yyk8yu 1 3 3\n'
        '9q8yymkye 1 5 5\n'
        '9q8yymky8 1 6 6\n'
        '9q8yyk8yt 1 7 7\n'
        'runs: 5 points: 5\n|',
      ),
    );

    final lengthSix = await runCli(
      ['trail', 'walk.csv', '--length', '6'],
      Inputs(
        stdin: () async => [],
        file: (path) => {
          'walk.csv': [
            32,
            32,
            35,
            32,
            109,
            111,
            114,
            110,
            105,
            110,
            103,
            32,
            119,
            97,
            108,
            107,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            49,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            49,
            10,
            32,
            32,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            57,
            48,
            44,
            32,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            52,
            48,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            57,
            48,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            52,
            49,
            10,
            32,
            32,
            51,
            55,
            46,
            55,
            55,
            52,
            57,
            44,
            45,
            49,
            50,
            50,
            46,
            52,
            49,
            57,
            52,
            10,
          ],
        }[path],
      ),
    );
    expect(
      '${lengthSix.code}|${lengthSix.out}|${lengthSix.err}',
      equals(
        '0|9q8yyk 2 2 3\n'
        '9q8yym 2 5 6\n'
        '9q8yyk 1 7 7\n'
        'runs: 3 points: 5\n|',
      ),
    );
  });

  test(
    'handles empty input and aggregates same-cell Maidenhead points',
    () async {
      final empty = await runCli([
        'trail',
        '-',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${empty.code}|${empty.out}|${empty.err}',
        equals('0|runs: 0 points: 0\n|'),
      );

      final maidenhead = await runCli(
        ['trail', '-', '--system', 'maidenhead'],
        Inputs(
          stdin: () async => [
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
            48,
            44,
            48,
            10,
          ],
          file: (path) => null,
        ),
      );
      expect(
        '${maidenhead.code}|${maidenhead.out}|${maidenhead.err}',
        equals('0|JJ00aa 16 1 16\nruns: 1 points: 16\n|'),
      );
    },
  );

  test(
    'preserves CRLF, comments, blank lines, malformed rows, and line numbers',
    () async {
      final physicalLine = await runCli(
        ['trail', 'walk.csv'],
        Inputs(
          stdin: () async => [],
          file: (path) => {
            'walk.csv': [35, 10, 10, 57, 49, 44, 48, 10],
          }[path],
        ),
      );
      expect(
        '${physicalLine.code}|${physicalLine.out}|${physicalLine.err}',
        equals('1||latcell: walk.csv:3: latitude 91 is outside -90..90\n'),
      );

      final malformed = await runCli(
        ['trail', '-'],
        Inputs(
          stdin: () async => [35, 13, 10, 32, 9, 13, 10, 49, 10],
          file: (path) => null,
        ),
      );
      expect(
        '${malformed.code}|${malformed.out}|${malformed.err}',
        equals('1||latcell: <stdin>:3: expected LAT,LON\n'),
      );
    },
  );

  test(
    'removes one leading BOM and rejects a second BOM in coordinate text',
    () async {
      final singleBom = await runCli(
        ['trail', '-'],
        Inputs(
          stdin: () async => [239, 187, 191, 48, 44, 48, 10],
          file: (path) => null,
        ),
      );
      expect(
        '${singleBom.code}|${singleBom.out}|${singleBom.err}',
        equals('0|s00000000 1 1 1\nruns: 1 points: 1\n|'),
      );

      final doubleBom = await runCli(
        ['trail', '-'],
        Inputs(
          stdin: () async => [239, 187, 191, 239, 187, 191, 48, 44, 48, 10],
          file: (path) => null,
        ),
      );
      expect(
        '${doubleBom.code}|${doubleBom.out}|${doubleBom.err}',
        equals(
          '1||latcell: <stdin>:1: latitude \uFEFF0 is not a decimal number\n',
        ),
      );
    },
  );

  test('reports input failures and validates length before reading', () async {
    final missing = await runCli([
      'trail',
      'walk.csv',
    ], Inputs(stdin: () async => [], file: (path) => null));
    expect(
      '${missing.code}|${missing.out}|${missing.err}',
      equals('2||latcell: cannot read walk.csv\n'),
    );

    final invalidUtf8 = await runCli([
      'trail',
      '-',
    ], Inputs(stdin: () async => [255], file: (path) => null));
    expect(
      '${invalidUtf8.code}|${invalidUtf8.out}|${invalidUtf8.err}',
      equals('2||latcell: <stdin>: input is not valid UTF-8\n'),
    );

    final invalidLength = await runCli([
      'trail',
      'walk.csv',
      '--length',
      '13',
    ], Inputs(stdin: () async => [], file: (path) => null));
    expect(
      '${invalidLength.code}|${invalidLength.out}|${invalidLength.err}',
      equals('1||latcell: length 13 is not valid for geohash (1..12)\n'),
    );
  });

  test(
    'validates trail system, length syntax, arity, and option restrictions',
    () async {
      final unknownSystem = await runCli([
        'trail',
        '-',
        '--system',
        'nope',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${unknownSystem.code}|${unknownSystem.out}|${unknownSystem.err}',
        equals('2||latcell: unknown system nope\n'),
      );

      final invalidLengthSyntax = await runCli([
        'trail',
        '-',
        '--length',
        '+5',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${invalidLengthSyntax.code}|${invalidLengthSyntax.out}|'
        '${invalidLengthSyntax.err}',
        equals('2||latcell: option --length needs a whole number, got +5\n'),
      );

      final missingFile = await runCli([
        'trail',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${missingFile.code}|${missingFile.out}|${missingFile.err}',
        equals(
          '2||latcell: usage: latcell trail FILE [--system SYSTEM] [--length N]\n',
        ),
      );

      final extraFile = await runCli([
        'trail',
        'walk.csv',
        'extra.csv',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${extraFile.code}|${extraFile.out}|${extraFile.err}',
        equals(
          '2||latcell: usage: latcell trail FILE [--system SYSTEM] [--length N]\n',
        ),
      );

      final unsupportedOption = await runCli([
        'trail',
        '-',
        '--box',
        '0,0,0,0',
      ], Inputs(stdin: () async => [], file: (path) => null));
      expect(
        '${unsupportedOption.code}|${unsupportedOption.out}|'
        '${unsupportedOption.err}',
        equals('2||latcell: unknown option --box\n'),
      );
    },
  );
}
