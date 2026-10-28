import 'package:test/test.dart';
import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/base/text.dart';

void main() {
  test('folds ASCII letters and preserves non-ASCII characters', () {
    expect(asciiLower('Az09É'), equals('az09É'));
    expect(asciiUpper('aZ09é'), equals('AZ09é'));
    expect(asciiLower('AZ'), equals('az'));
    expect(asciiUpper('az'), equals('AZ'));
    expect(asciiLower('É'), equals('É'));
    expect(asciiUpper('é'), equals('é'));
  });

  test('trims only edge spaces and tabs', () {
    expect(trimBlanks(' \t x \t '), equals('x'));
    expect(trimBlanks('\nx\r'), equals('\nx\r'));
    expect(asciiLower(''), equals(''));
    expect(asciiUpper(''), equals(''));
    expect(trimBlanks(''), equals(''));
    expect(trimBlanks(' \t '), equals(''));
    expect(trimBlanks('\t\t'), equals(''));
  });

  test('decodes valid UTF-8 and removes only one leading BOM', () {
    expect(decodeUtf8([0x31, 0x2c, 0x32], 'walk.csv'), equals('1,2'));
    expect(decodeUtf8([0xef, 0xbb, 0xbf, 0x61], 'walk.csv'), equals('a'));
    expect(
      decodeUtf8([0xef, 0xbb, 0xbf, 0xef, 0xbb, 0xbf, 0x61], 'walk.csv'),
      equals('\uFEFFa'),
    );
  });

  test('rejects malformed UTF-8 byte sequences', () {
    expect(
      () => decodeUtf8([0xc0, 0xaf], 'walk.csv'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv: input is not valid UTF-8',
            ),
      ),
    );
    expect(
      () => decodeUtf8([0xed, 0xa0, 0x80], 'walk.csv'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv: input is not valid UTF-8',
            ),
      ),
    );
    expect(
      () => decodeUtf8([0xf4, 0x90, 0x80, 0x80], 'walk.csv'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv: input is not valid UTF-8',
            ),
      ),
    );
    expect(
      () => decodeUtf8([0xe2, 0x82], 'walk.csv'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv: input is not valid UTF-8',
            ),
      ),
    );
    expect(
      () => decodeUtf8([0xff], 'walk.csv'),
      throwsA(
        isA<Failure>()
            .having((failure) => failure.code, 'code', 2)
            .having(
              (failure) => failure.message,
              'message',
              'walk.csv: input is not valid UTF-8',
            ),
      ),
    );
  });

  test('splits LF lines and removes only CR before LF', () {
    expect(splitLines(''), equals([]));
    expect(splitLines('a\n'), equals(['a']));
    expect(splitLines('a\n\n'), equals(['a', '']));
    expect(splitLines('a\r\nb\r'), equals(['a', 'b\r']));
    expect(splitLines('a\rb'), equals(['a\rb']));
  });
}
