import '../base/failure.dart';
import '../base/text.dart';
import '../codec/systems.dart';
import '../num/decimal.dart';
import '../num/frac.dart';

class Run {
  Run(this.code, this.first) : last = first;

  final String code;
  int count = 1;
  final int first;
  int last;
}

class Trail {
  const Trail(this.runs, this.points);

  final List<Run> runs;
  final int points;
}

Trail readTrail(String text, String label, String system, int length) {
  final runs = <Run>[];
  var points = 0;
  final lines = splitLines(text);

  for (var index = 0; index < lines.length; index++) {
    final lineNumber = index + 1;
    final line = trimBlanks(lines[index]);
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    final fields = line.split(',');
    if (fields.length != 2) {
      throw Failure(1, '$label:$lineNumber: expected LAT,LON');
    }

    final latitude = _parseCoordinate(
      trimBlanks(fields[0]),
      label,
      lineNumber,
      parseLat,
    );
    final longitude = _parseCoordinate(
      trimBlanks(fields[1]),
      label,
      lineNumber,
      parseLon,
    );
    final code = encodeIn(system, latitude, longitude, length);
    points++;
    if (runs.isNotEmpty && runs.last.code == code) {
      runs.last.count++;
      runs.last.last = lineNumber;
    } else {
      runs.add(Run(code, lineNumber));
    }
  }

  return Trail(runs, points);
}

Frac _parseCoordinate(
  String text,
  String label,
  int lineNumber,
  Frac Function(String) parse,
) {
  try {
    return parse(text);
  } on Failure catch (failure) {
    throw Failure(failure.code, '$label:$lineNumber: ${failure.message}');
  }
}
