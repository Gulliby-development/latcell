import 'package:test/test.dart';
import 'package:latcell/src/base/failure.dart';

void main() {
  test('exposes failure code, message and text', () {
    const failure = Failure(2, 'bad');

    expect(failure.code, equals(2));
    expect(failure.message, equals('bad'));
    expect(failure.toString(), equals('bad'));
  });
}
