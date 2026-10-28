import 'package:test/test.dart';
import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/geo/trail.dart';

void main() {
  test('exposes mutable run fields through a trail', () {
    final run = Run('9q8yyk', 8);
    run.count = 3;
    run.last = 12;
    final trail = Trail([run], 3);
    expect((
      trail.points,
      trail.runs.length,
      trail.runs[0].code,
      trail.runs[0].count,
      trail.runs[0].first,
      trail.runs[0].last,
    ), equals((3, 1, '9q8yyk', 3, 8, 12)));
  });

  test('reads the supplied walk at length nine', () {
    final trail = readTrail(
      '# morning walk\n'
          '37.7749,-122.4194\n'
          '37.77491,-122.41941\n'
          '\n'
          '37.7790, -122.4140\n'
          '37.7790,-122.4141\n'
          '37.7749,-122.4194',
      'walk.csv',
      'geohash',
      9,
    );
    expect(
      (
        trail.points,
        trail.runs.length,
        (
          trail.runs[0].code,
          trail.runs[0].count,
          trail.runs[0].first,
          trail.runs[0].last,
        ),
        (
          trail.runs[1].code,
          trail.runs[1].count,
          trail.runs[1].first,
          trail.runs[1].last,
        ),
        (
          trail.runs[2].code,
          trail.runs[2].count,
          trail.runs[2].first,
          trail.runs[2].last,
        ),
        (
          trail.runs[3].code,
          trail.runs[3].count,
          trail.runs[3].first,
          trail.runs[3].last,
        ),
        (
          trail.runs[4].code,
          trail.runs[4].count,
          trail.runs[4].first,
          trail.runs[4].last,
        ),
      ),
      equals((
        5,
        5,
        ('9q8yyk8yt', 1, 2, 2),
        ('9q8yyk8yu', 1, 3, 3),
        ('9q8yymkye', 1, 5, 5),
        ('9q8yymky8', 1, 6, 6),
        ('9q8yyk8yt', 1, 7, 7),
      )),
    );
  });

  test('reads the supplied walk at length six', () {
    final trail = readTrail(
      '# morning walk\n'
          '37.7749,-122.4194\n'
          '37.77491,-122.41941\n'
          '\n'
          '37.7790, -122.4140\n'
          '37.7790,-122.4141\n'
          '37.7749,-122.4194',
      'walk.csv',
      'geohash',
      6,
    );
    expect(
      (
        trail.points,
        trail.runs.length,
        (
          trail.runs[0].code,
          trail.runs[0].count,
          trail.runs[0].first,
          trail.runs[0].last,
        ),
        (
          trail.runs[1].code,
          trail.runs[1].count,
          trail.runs[1].first,
          trail.runs[1].last,
        ),
        (
          trail.runs[2].code,
          trail.runs[2].count,
          trail.runs[2].first,
          trail.runs[2].last,
        ),
      ),
      equals((
        5,
        3,
        ('9q8yyk', 2, 2, 3),
        ('9q8yym', 2, 5, 6),
        ('9q8yyk', 1, 7, 7),
      )),
    );
  });

  test('starts a new run when a code returns after another code', () {
    final trail = readTrail(
      '37.7749,-122.4194\n'
          '37.7790,-122.4140\n'
          '37.7749,-122.4194',
      'return.csv',
      'geohash',
      6,
    );
    expect(
      (
        trail.points,
        trail.runs.length,
        (
          trail.runs[0].code,
          trail.runs[0].count,
          trail.runs[0].first,
          trail.runs[0].last,
        ),
        (
          trail.runs[1].code,
          trail.runs[1].count,
          trail.runs[1].first,
          trail.runs[1].last,
        ),
        (
          trail.runs[2].code,
          trail.runs[2].count,
          trail.runs[2].first,
          trail.runs[2].last,
        ),
      ),
      equals((
        3,
        3,
        ('9q8yyk', 1, 1, 1),
        ('9q8yym', 1, 2, 2),
        ('9q8yyk', 1, 3, 3),
      )),
    );
  });

  test('trims fields and skips blank and comment lines with CRLF', () {
    final trail = readTrail(
      '# heading\r\n'
          ' \t\r\n'
          '\t37.7749 \t, \t-122.4194\t\r\n'
          '# another comment\r\n'
          '37.77491,-122.41941',
      'walk.csv',
      'geohash',
      6,
    );
    expect((
      trail.points,
      trail.runs.length,
      trail.runs[0].code,
      trail.runs[0].count,
      trail.runs[0].first,
      trail.runs[0].last,
    ), equals((2, 1, '9q8yyk', 2, 3, 5)));
  });

  test('returns no points for empty and skipped-only trails', () {
    final empty = readTrail('', 'empty.csv', 'geohash', 9);
    final skipped = readTrail(
      ' \t\n# no points\n\t\n',
      'skipped.csv',
      'geohash',
      9,
    );
    expect((
      empty.points,
      empty.runs.length,
      skipped.points,
      skipped.runs.length,
    ), equals((0, 0, 0, 0)));
  });

  test('dispatches trail coordinates to another grid system', () {
    final trail = readTrail('37.7749,-122.4194', 'walk.csv', 'maidenhead', 6);
    expect((
      trail.points,
      trail.runs.length,
      trail.runs[0].code,
      trail.runs[0].count,
      trail.runs[0].first,
      trail.runs[0].last,
    ), equals((1, 1, 'CM87ss', 1, 1, 1)));
  });

  test('labels syntax, numeric, and non-blank line failures', () {
    expect(
      () => readTrail('37.7749\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:1: expected LAT,LON',
            ),
      ),
    );
    expect(
      () => readTrail('1,2,3\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:1: expected LAT,LON',
            ),
      ),
    );
    expect(
      () => readTrail('# skipped\nabc,0\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:2: latitude abc is not a decimal number',
            ),
      ),
    );
    expect(
      () => readTrail('# morning walk\n\n91,0\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:3: latitude 91 is outside -90..90',
            ),
      ),
    );
    expect(
      () => readTrail('0,181\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:1: longitude 181 is outside -180..180',
            ),
      ),
    );
    expect(
      () => readTrail('0,west\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:1: longitude west is not a decimal number',
            ),
      ),
    );
    expect(
      () => readTrail('\u00a0\n', 'walk.csv', 'geohash', 9),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv:1: expected LAT,LON',
            ),
      ),
    );
  });
}
