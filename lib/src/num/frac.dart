class Frac implements Comparable<Frac> {
  factory Frac(BigInt numerator, [BigInt? denominator]) {
    final suppliedDenominator = denominator ?? BigInt.one;
    if (suppliedDenominator == BigInt.zero) {
      throw ArgumentError.value(suppliedDenominator, 'denominator');
    }
    if (numerator == BigInt.zero) {
      return Frac._(BigInt.zero, BigInt.one);
    }

    final sign = suppliedDenominator.isNegative ? -BigInt.one : BigInt.one;
    final positiveNumerator = numerator * sign;
    final positiveDenominator = suppliedDenominator.abs();
    final divisor = _greatestCommonDivisor(
      positiveNumerator.abs(),
      positiveDenominator,
    );
    return Frac._(positiveNumerator ~/ divisor, positiveDenominator ~/ divisor);
  }

  factory Frac.of(int numerator, [int denominator = 1]) =>
      Frac(BigInt.from(numerator), BigInt.from(denominator));

  Frac._(this.numerator, this.denominator);

  final BigInt numerator;
  final BigInt denominator;

  Frac operator +(Frac other) => Frac(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );

  Frac operator -(Frac other) => Frac(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );

  Frac operator *(Frac other) =>
      Frac(numerator * other.numerator, denominator * other.denominator);

  Frac operator /(Frac other) {
    if (other.numerator == BigInt.zero) {
      throw ArgumentError.value(other, 'other', 'cannot divide by zero');
    }
    return Frac(numerator * other.denominator, denominator * other.numerator);
  }

  Frac operator -() => Frac(-numerator, denominator);

  bool operator <(Frac other) => compareTo(other) < 0;

  bool operator >(Frac other) => compareTo(other) > 0;

  bool operator <=(Frac other) => compareTo(other) <= 0;

  bool operator >=(Frac other) => compareTo(other) >= 0;

  @override
  int compareTo(Frac other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  @override
  bool operator ==(Object other) =>
      other is Frac &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  bool get isNegative => numerator.isNegative;

  BigInt floor() {
    final quotient = numerator ~/ denominator;
    final remainder = numerator.remainder(denominator);
    if (numerator.isNegative && remainder != BigInt.zero) {
      return quotient - BigInt.one;
    }
    return quotient;
  }

  String toFixed(int places) {
    if (places < 1) {
      throw ArgumentError.value(places, 'places', 'must be at least 1');
    }

    final scale = BigInt.from(10).pow(places);
    final scaledNumerator = numerator.abs() * scale;
    var roundedMagnitude = scaledNumerator ~/ denominator;
    final remainder = scaledNumerator.remainder(denominator);
    if (remainder * BigInt.two >= denominator) {
      roundedMagnitude += BigInt.one;
    }

    final digits = roundedMagnitude.toString().padLeft(places + 1, '0');
    final integerPart = digits.substring(0, digits.length - places);
    final fractionalPart = digits.substring(digits.length - places);
    final sign = numerator.isNegative && roundedMagnitude != BigInt.zero
        ? '-'
        : '';
    return '$sign$integerPart.$fractionalPart';
  }

  @override
  String toString() => '$numerator/$denominator';
}

BigInt _greatestCommonDivisor(BigInt left, BigInt right) {
  var a = left;
  var b = right;
  while (b != BigInt.zero) {
    final remainder = a.remainder(b);
    a = b;
    b = remainder;
  }
  return a;
}
