import 'package:test/test.dart';
import 'package:latcell/src/num/frac.dart';

void main() {
  test('builds reduced fractions and does arithmetic', () {
    expect(Frac.of(2, 4).toString(), equals('1/2'));
    expect(Frac.of(1, -2).toString(), equals('-1/2'));
    expect(Frac.of(0, 5).toString(), equals('0/1'));
    expect((Frac.of(1, 2) + Frac.of(1, 3)).toString(), equals('5/6'));
    expect((Frac.of(1, 2) - Frac.of(1, 3)).toString(), equals('1/6'));
    expect((Frac.of(2, 3) * Frac.of(3, 4)).toString(), equals('1/2'));
    expect((Frac.of(2, 3) / Frac.of(4, 3)).toString(), equals('1/2'));
    expect((-Frac.of(2, 3)).toString(), equals('-2/3'));
  });
  test('compares exactly', () {
    expect(Frac.of(1, 3) < Frac.of(1, 2), equals(true));
    expect(Frac.of(1, 2) <= Frac.of(2, 4), equals(true));
    expect(Frac.of(-1, 2) > Frac.of(-2, 3), equals(true));
    expect(Frac.of(1, 2) >= Frac.of(2, 3), equals(false));
    expect(Frac.of(1, 2) == Frac.of(3, 6), equals(true));
    expect(Frac.of(1, 2).isNegative, equals(false));
    expect(Frac.of(-1, 2).isNegative, equals(true));
  });
  test('formats fixed decimals with half-away rounding', () {
    expect(Frac.of(1, 3).toFixed(7), equals('0.3333333'));
    expect(Frac.of(2, 3).toFixed(7), equals('0.6666667'));
    expect(Frac.of(-1, 3).toFixed(7), equals('-0.3333333'));
    expect(Frac.of(1, 8).toFixed(2), equals('0.13'));
    expect(Frac.of(-1, 8).toFixed(2), equals('-0.13'));
    expect(Frac.of(1, 20000000).toFixed(7), equals('0.0000001'));
    expect(Frac.of(-1, 30000000).toFixed(7), equals('0.0000000'));
    expect(Frac.of(999999995, 1000000000).toFixed(7), equals('1.0000000'));
    expect(Frac.of(5, 2).toFixed(3), equals('2.500'));
  });

  test('floors toward negative infinity', () {
    expect(Frac.of(-1, 2).floor(), equals(BigInt.from(-1)));
    expect(Frac.of(-2).floor(), equals(BigInt.from(-2)));
    expect(Frac.of(5, 2).floor(), equals(BigInt.from(2)));
  });

  test('exposes normalized fields and exact large integer behavior', () {
    expect(Frac.of(10, 12).numerator, equals(BigInt.from(5)));
    expect(Frac.of(10, 12).denominator, equals(BigInt.from(6)));
    expect(Frac.of(1, 3).compareTo(Frac.of(1, 2)), equals(-1));
    expect(Frac.of(1, 2).hashCode, equals(Frac.of(2, 4).hashCode));
    expect(
      Frac(BigInt.parse('9007199254740993'), BigInt.from(10)).toString(),
      equals('9007199254740993/10'),
    );
    expect(
      (Frac(BigInt.parse('9007199254740993')) / Frac.of(3)).toString(),
      equals('3002399751580331/1'),
    );
  });
}
