import '../num/frac.dart';

class Cell {
  const Cell(this.latLo, this.latHi, this.lonLo, this.lonHi);

  final Frac latLo;
  final Frac latHi;
  final Frac lonLo;
  final Frac lonHi;

  Frac get centerLat => (latLo + latHi) / Frac.of(2);

  Frac get centerLon => (lonLo + lonHi) / Frac.of(2);
}

class Decoded {
  const Decoded(this.cell, this.code);

  final Cell cell;
  final String code;
}

int cellIndex(Frac v, int lo, int span, int count) {
  final scaledIndex = ((v - Frac.of(lo)) * Frac.of(count, span)).floor();
  final maximum = BigInt.from(count) - BigInt.one;
  if (scaledIndex < BigInt.zero) {
    return 0;
  }
  if (scaledIndex > maximum) {
    return maximum.toInt();
  }
  return scaledIndex.toInt();
}
