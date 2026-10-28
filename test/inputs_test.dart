import 'package:test/test.dart';

import 'package:latcell/src/base/failure.dart';
import 'package:latcell/src/base/inputs.dart';

void main() {
  test('reads standard input without calling the file callback', () async {
    final inputs = Inputs(
      stdin: () async => [49, 44, 50],
      file: (path) => throw StateError('file callback should not be called'),
    );

    expect(await inputs.read('-'), equals(('<stdin>', '1,2')));
  });

  test('reads a file without calling the stdin callback', () async {
    final inputs = Inputs(
      stdin: () async =>
          throw StateError('stdin callback should not be called'),
      file: (path) => {
        'walk.csv': [49, 44, 50],
      }[path],
    );

    expect(await inputs.read('walk.csv'), equals(('walk.csv', '1,2')));
  });

  test('reports an unreadable file', () async {
    final inputs = Inputs(
      stdin: () async =>
          throw StateError('stdin callback should not be called'),
      file: (path) => null,
    );
    Failure? failure;

    try {
      await inputs.read('missing.csv');
    } on Failure catch (error) {
      failure = error;
    }

    expect(
      failure,
      isA<Failure>()
          .having((error) => error.code, 'code', 2)
          .having(
            (error) => error.message,
            'message',
            'cannot read missing.csv',
          ),
    );
  });

  test('reports invalid UTF-8 from standard input', () async {
    final inputs = Inputs(
      stdin: () async => [255],
      file: (path) => throw StateError('file callback should not be called'),
    );
    Failure? failure;

    try {
      await inputs.read('-');
    } on Failure catch (error) {
      failure = error;
    }

    expect(
      failure,
      isA<Failure>()
          .having((error) => error.code, 'code', 2)
          .having(
            (error) => error.message,
            'message',
            '<stdin>: input is not valid UTF-8',
          ),
    );
  });

  test('reports invalid UTF-8 from a file', () async {
    final inputs = Inputs(
      stdin: () async =>
          throw StateError('stdin callback should not be called'),
      file: (path) => {
        'walk.csv': [255],
      }[path],
    );
    Failure? failure;

    try {
      await inputs.read('walk.csv');
    } on Failure catch (error) {
      failure = error;
    }

    expect(
      failure,
      isA<Failure>()
          .having((error) => error.code, 'code', 2)
          .having(
            (error) => error.message,
            'message',
            'walk.csv: input is not valid UTF-8',
          ),
    );
  });

  test('decodes a single leading BOM from a file', () async {
    final inputs = Inputs(
      stdin: () async =>
          throw StateError('stdin callback should not be called'),
      file: (path) => {
        'walk.csv': [239, 187, 191, 97],
      }[path],
    );

    expect(await inputs.read('walk.csv'), equals(('walk.csv', 'a')));
  });

  test('removes only one leading BOM from standard input', () async {
    final inputs = Inputs(
      stdin: () async => [239, 187, 191, 239, 187, 191, 97],
      file: (path) => throw StateError('file callback should not be called'),
    );

    expect(await inputs.read('-'), equals(('<stdin>', '\uFEFFa')));
  });
}
