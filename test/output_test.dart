import 'package:test/test.dart';

import 'package:latcell/src/base/output.dart';

void main() {
  test('exposes outcome fields', () {
    const outcome = Outcome(1, 'out\n', 'err\n');

    expect(outcome.code, equals(1));
    expect(outcome.out, equals('out\n'));
    expect(outcome.err, equals('err\n'));
  });
}
