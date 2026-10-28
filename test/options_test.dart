import 'package:test/test.dart';
import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/base/options.dart';

void main() {
  test('parses option forms and positional arguments', () {
    final separated = parseOptions(['-5', '-', '--length', '005'], ['length']);
    expect(separated.positionals, equals(['-5', '-']));
    expect(separated.options, equals({'length': '005'}));
    expect(separated.intOption('length') == 5, equals(true));

    final equalsForm = parseOptions(['--length=6', 'x'], ['length']);
    expect(equalsForm.positionals, equals(['x']));
    expect(equalsForm.options, equals({'length': '6'}));
    expect(equalsForm.intOption('length'), equals(6));

    final terminated = parseOptions(['--', '--length', '6'], ['length']);
    expect(terminated.positionals, equals(['--length', '6']));
    expect(terminated.options, equals({}));
    expect(Parsed([], {}).intOption('length'), isNull);
    expect(() => Parsed(['x'], {}).expect(1, 'near CODE'), returnsNormally);
  });

  test('rejects unknown, missing, repeated, and excess positional inputs', () {
    expect(
      () => parseOptions(['--x=1'], ['length']),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'unknown option --x',
            ),
      ),
    );
    expect(
      () => parseOptions(['--length'], ['length']),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a value',
            ),
      ),
    );
    expect(
      () => parseOptions(['--length', '--x'], ['length']),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a value',
            ),
      ),
    );
    expect(
      () => parseOptions(['--length=1', '--length=2'], ['length']),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length given twice',
            ),
      ),
    );
    expect(
      () => Parsed([], {}).expect(1, 'near CODE'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'usage: latcell near CODE',
            ),
      ),
    );
  });

  test('validates whole-number option boundaries', () {
    expect(
      () => Parsed([], {'length': ''}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got ',
            ),
      ),
    );
    expect(
      () => Parsed([], {'length': '-1'}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got -1',
            ),
      ),
    );
    expect(
      () => Parsed([], {'length': '+1'}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got +1',
            ),
      ),
    );
    expect(
      () => Parsed([], {'length': '1.0'}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got 1.0',
            ),
      ),
    );
    expect(
      () => Parsed([], {'length': '1234567'}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got 1234567',
            ),
      ),
    );
    expect(
      () => Parsed([], {'length': '１'}).intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got １',
            ),
      ),
    );
    expect(Parsed([], {'length': '0'}).intOption('length'), equals(0));
    expect(
      Parsed([], {'length': '999999'}).intOption('length'),
      equals(999999),
    );
  });

  test('preserves empty values and interleaved positionals', () {
    final parsed = parseOptions(['before', '--length=7', 'after'], ['length']);
    expect(parsed.positionals, equals(['before', 'after']));
    expect(parsed.options, equals({'length': '7'}));

    final empty = parseOptions(['--length='], ['length']);
    expect(empty.options, equals({'length': ''}));
    expect(
      () => empty.intOption('length'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'option --length needs a whole number, got ',
            ),
      ),
    );
  });

  test('splits equals values at the first separator', () {
    final parsed = parseOptions(['left', '--length=a=b', 'right'], ['length']);
    expect(parsed.options, equals({'length': 'a=b'}));
    expect(parsed.positionals, equals(['left', 'right']));
    expect(
      parseOptions(['--length', '-5'], ['length']).options,
      equals({'length': '-5'}),
    );
  });
}
