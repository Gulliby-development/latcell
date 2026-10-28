import 'package:test/test.dart';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

void main() {
  test('covers boxes in the specified order and trims box fields', () async {
    final ordinary = await runCli(
      ['cover', '--box', '37.77,-122.43,37.78,-122.41', '--length', '6'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${ordinary.code}|${ordinary.out}|${ordinary.err}',
      equals(
        '0|9q8yyj\n'
        '9q8yym\n'
        '9q8yyh\n'
        '9q8yyk\n'
        '9q8yy5\n'
        '9q8yy7\n|',
      ),
    );

    final trimmed = await runCli(
      [
        'cover',
        '--box',
        ' 37.77,\t-122.43,37.78, -122.41\t',
        '--length',
        '6',
        '--limit',
        '6',
      ],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${trimmed.code}|${trimmed.out}|${trimmed.err}',
      equals(
        '0|9q8yyj\n'
        '9q8yym\n'
        '9q8yyh\n'
        '9q8yyk\n'
        '9q8yy5\n'
        '9q8yy7\n|',
      ),
    );

    final degenerate = await runCli(
      ['cover', '--box', '0,0,0,0', '--length', '1'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${degenerate.code}|${degenerate.out}|${degenerate.err}',
      equals('0|s\n|'),
    );

    final antimeridian = await runCli(
      ['cover', '--box', '0,170,0,-170', '--length', '1'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${antimeridian.code}|${antimeridian.out}|${antimeridian.err}',
      equals('0|x\n8\n|'),
    );
  });

  test('uses the default limit and accepts explicit limits', () async {
    final defaultLimit = await runCli(
      ['cover', '--box', '37,-123,38,-122', '--length', '5'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${defaultLimit.code}|${defaultLimit.out}|${defaultLimit.err}',
      equals('1||latcell: box needs 552 cells at length 5; the limit is 100\n'),
    );

    final explicitLimitFailure = await runCli(
      [
        'cover',
        '--box',
        '37.77,-122.43,37.78,-122.41',
        '--length',
        '6',
        '--limit',
        '5',
      ],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${explicitLimitFailure.code}|${explicitLimitFailure.out}|'
      '${explicitLimitFailure.err}',
      equals('1||latcell: box needs 6 cells at length 6; the limit is 5\n'),
    );

    final zeroLimit = await runCli(
      ['cover', '--box', '0,0,0,0', '--length', '1', '--limit', '0'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${zeroLimit.code}|${zeroLimit.out}|${zeroLimit.err}',
      equals('1||latcell: box needs 1 cells at length 1; the limit is 0\n'),
    );
  });

  test('checks required options and whole numbers before the box', () async {
    final missingBox = await runCli(
      ['cover'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${missingBox.code}|${missingBox.out}|${missingBox.err}',
      equals('2||latcell: option --box is required\n'),
    );

    final missingLength = await runCli(
      ['cover', '--box', 'bad'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${missingLength.code}|${missingLength.out}|${missingLength.err}',
      equals('2||latcell: option --length is required\n'),
    );

    final invalidLengthNumber = await runCli(
      ['cover', '--box', 'bad', '--length', 'x'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${invalidLengthNumber.code}|${invalidLengthNumber.out}|${invalidLengthNumber.err}',
      equals('2||latcell: option --length needs a whole number, got x\n'),
    );

    final invalidLimitNumber = await runCli(
      ['cover', '--box', 'bad', '--length', '1', '--limit', 'x'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${invalidLimitNumber.code}|${invalidLimitNumber.out}|${invalidLimitNumber.err}',
      equals('2||latcell: option --limit needs a whole number, got x\n'),
    );

    final malformedBoxBeforeLength = await runCli(
      ['cover', '--box', 'bad', '--length', '13'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${malformedBoxBeforeLength.code}|${malformedBoxBeforeLength.out}|'
      '${malformedBoxBeforeLength.err}',
      equals('2||latcell: option --box needs S,W,N,E\n'),
    );
  });

  test('validates box coordinates and geohash length', () async {
    final inverted = await runCli(
      ['cover', '--box', '2,0,1,0', '--length', '1'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${inverted.code}|${inverted.out}|${inverted.err}',
      equals('1||latcell: box south 2 is above north 1\n'),
    );

    final invalidCoordinate = await runCli(
      ['cover', '--box', 'bad,0,1,0', '--length', '1'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${invalidCoordinate.code}|${invalidCoordinate.out}|${invalidCoordinate.err}',
      equals('1||latcell: latitude bad is not a decimal number\n'),
    );

    final invalidGeohashLength = await runCli(
      ['cover', '--box', '0,0,0,0', '--length', '13'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${invalidGeohashLength.code}|${invalidGeohashLength.out}|'
      '${invalidGeohashLength.err}',
      equals('1||latcell: length 13 is not valid for geohash (1..12)\n'),
    );
  });

  test('rejects wrong arity and undocumented options', () async {
    final positional = await runCli(
      ['cover', 'extra'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${positional.code}|${positional.out}|${positional.err}',
      equals(
        '2||latcell: usage: latcell cover --box S,W,N,E --length N [--limit M]\n',
      ),
    );

    final undocumentedOption = await runCli(
      ['cover', '--system', 'geohash'],
      Inputs(
        stdin: () async => <int>[],
        file: (path) => <String, List<int>>{}[path],
      ),
    );
    expect(
      '${undocumentedOption.code}|${undocumentedOption.out}|'
      '${undocumentedOption.err}',
      equals('2||latcell: unknown option --system\n'),
    );
  });
}
