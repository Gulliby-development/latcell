import '../base/failure.dart';
import '../base/options.dart';
import '../base/text.dart';
import '../geo/cover.dart';
import '../num/decimal.dart';
import '../codec/systems.dart';

String coverCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['box', 'length', 'limit']);
  parsed.expect(0, 'cover --box S,W,N,E --length N [--limit M]');

  if (!parsed.options.containsKey('box')) {
    throw const Failure(2, 'option --box is required');
  }
  if (!parsed.options.containsKey('length')) {
    throw const Failure(2, 'option --length is required');
  }

  final length = parsed.intOption('length');
  if (length == null) {
    throw const Failure(2, 'option --length is required');
  }
  final limit = parsed.intOption('limit') ?? 100;
  final values = parsed.options['box']!.split(',');
  if (values.length != 4) {
    throw const Failure(2, 'option --box needs S,W,N,E');
  }

  final southText = trimBlanks(values[0]);
  final westText = trimBlanks(values[1]);
  final northText = trimBlanks(values[2]);
  final eastText = trimBlanks(values[3]);
  final south = parseLat(southText);
  final west = parseLon(westText);
  final north = parseLat(northText);
  final east = parseLon(eastText);
  if (south > north) {
    throw Failure(1, 'box south $southText is above north $northText');
  }

  checkLength('geohash', length);
  final codes = coverBox(Box(south, west, north, east), length, limit);
  return '${codes.join('\n')}\n';
}
