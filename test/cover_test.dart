import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/geo/cover.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('covers the supplied San Francisco box in row-major order', () {
    expect(
      coverBox(
        Box(
          Frac.of(3777, 100),
          Frac.of(-12243, 100),
          Frac.of(3778, 100),
          Frac.of(-12241, 100),
        ),
        6,
        6,
      ),
      equals(['9q8yyj', '9q8yym', '9q8yyh', '9q8yyk', '9q8yy5', '9q8yy7']),
    );
  });

  test('rejects the San Francisco box just below its exact limit', () {
    expect(
      () => coverBox(
        Box(
          Frac.of(3777, 100),
          Frac.of(-12243, 100),
          Frac.of(3778, 100),
          Frac.of(-12241, 100),
        ),
        6,
        5,
      ),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'box needs 6 cells at length 6; the limit is 5',
            ),
      ),
    );
  });

  test('rejects same-column antimeridian coverage over its limit', () {
    expect(
      () =>
          coverBox(Box(Frac.of(0), Frac.of(10), Frac.of(0), Frac.of(5)), 1, 7),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'box needs 8 cells at length 1; the limit is 7',
            ),
      ),
    );
  });

  test('reports the supplied 552-cell limit diagnostic', () {
    expect(
      () => coverBox(
        Box(Frac.of(37), Frac.of(-123), Frac.of(38), Frac.of(-122)),
        5,
        100,
      ),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'box needs 552 cells at length 5; the limit is 100',
            ),
      ),
    );
  });

  test('covers a zero-area box', () {
    expect(
      coverBox(Box(Frac.of(0), Frac.of(0), Frac.of(0), Frac.of(0)), 1, 1),
      equals(['s']),
    );
  });

  test('covers a zero-width box from north to south', () {
    expect(
      coverBox(Box(Frac.of(0), Frac.of(0), Frac.of(90), Frac.of(0)), 1, 2),
      equals(['u', 's']),
    );
  });

  test('covers a zero-height box from west to east', () {
    expect(
      coverBox(Box(Frac.of(0), Frac.of(0), Frac.of(0), Frac.of(45)), 1, 2),
      equals(['s', 't']),
    );
  });

  test('includes cells on all four shared-edge corners', () {
    expect(
      coverBox(Box(Frac.of(-45), Frac.of(-45), Frac.of(0), Frac.of(0)), 1, 4),
      equals(['e', 's', '7', 'k']),
    );
  });

  test('wraps antimeridian columns west through the last column first', () {
    expect(
      [
        coverBox(
          Box(Frac.of(0), Frac.of(135), Frac.of(0), Frac.of(-135)),
          1,
          3,
        ),
        coverBox(Box(Frac.of(0), Frac.of(10), Frac.of(0), Frac.of(5)), 1, 8),
      ],
      equals([
        ['x', '8', '9'],
        ['s', 't', 'w', 'x', '8', '9', 'd', 'e'],
      ]),
    );
  });

  test('orders every cell of a world box north to south and west to east', () {
    expect(
      coverBox(
        Box(Frac.of(-90), Frac.of(-180), Frac.of(90), Frac.of(180)),
        1,
        32,
      ),
      equals([
        'b',
        'c',
        'f',
        'g',
        'u',
        'v',
        'y',
        'z',
        '8',
        '9',
        'd',
        'e',
        's',
        't',
        'w',
        'x',
        '2',
        '3',
        '6',
        '7',
        'k',
        'm',
        'q',
        'r',
        '0',
        '1',
        '4',
        '5',
        'h',
        'j',
        'n',
        'p',
      ]),
    );
  });

  test('clamps the lower-left and upper-right world edges', () {
    expect(
      [
        coverBox(
          Box(Frac.of(-90), Frac.of(-180), Frac.of(-90), Frac.of(-180)),
          1,
          1,
        ),
        coverBox(
          Box(Frac.of(90), Frac.of(180), Frac.of(90), Frac.of(180)),
          1,
          1,
        ),
      ],
      equals([
        ['0'],
        ['z'],
      ]),
    );
  });

  test('counts a full-world length-12 cover before materializing codes', () {
    expect(
      () => coverBox(
        Box(Frac.of(-90), Frac.of(-180), Frac.of(90), Frac.of(180)),
        12,
        100,
      ),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'box needs 1152921504606846976 cells at length 12; the limit is 100',
            ),
      ),
    );
  });
}
