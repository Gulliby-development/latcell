import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/num/decimal.dart';

void main() {
  test('parses valid latitude and longitude decimals exactly', () {
    expect(parseLat('37.7749').toFixed(12), equals('37.774900000000'));
    expect(parseLat('-0').toFixed(12), equals('0.000000000000'));
    expect(parseLat('+5').toFixed(12), equals('5.000000000000'));
    expect(parseLat('00012.5').toFixed(12), equals('12.500000000000'));
    expect(parseLat('-90.000').toFixed(12), equals('-90.000000000000'));
    expect(parseLat('90').toFixed(12), equals('90.000000000000'));
    expect(parseLon('-180').toFixed(12), equals('-180.000000000000'));
    expect(parseLon('180').toFixed(12), equals('180.000000000000'));
    expect(parseLat('1.123456789012').toFixed(12), equals('1.123456789012'));
  });

  test('rejects malformed latitude syntax with the exact failure', () {
    expect(
      () => parseLat('abc'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude abc is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat(''),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude  is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat('1e3'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude 1e3 is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat('.5'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude .5 is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat('5.'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude 5. is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat(' 5'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude  5 is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat('-'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude - is not a decimal number',
            ),
      ),
    );
  });

  test('checks precision before inclusive coordinate bounds', () {
    expect(
      () => parseLat('1.1234567890123'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude 1.1234567890123 has more than 12 decimals',
            ),
      ),
    );
    expect(
      () => parseLat('91'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude 91 is outside -90..90',
            ),
      ),
    );
    expect(
      () => parseLon('181'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'longitude 181 is outside -180..180',
            ),
      ),
    );
  });

  test('covers zero, lower bounds, ASCII syntax and direct parsing', () {
    expect(parseLat('0').toFixed(12), equals('0.000000000000'));
    expect(
      () => parseLat('-91'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude -91 is outside -90..90',
            ),
      ),
    );
    expect(
      () => parseLon('-181'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'longitude -181 is outside -180..180',
            ),
      ),
    );
    expect(
      () => parseLat('１'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude １ is not a decimal number',
            ),
      ),
    );
    expect(
      () => parseLat('5 '),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 1)
            .having(
              (failure) => failure.message,
              'message',
              'latitude 5  is not a decimal number',
            ),
      ),
    );
    expect(
      parseDecimal('1.25', 'altitude', 0, 2).toFixed(12),
      equals('1.250000000000'),
    );
  });
}
