import '../base/failure.dart';
import '../base/options.dart';
import '../codec/geohash.dart';

const List<String> _directions = <String>[
  'N',
  'NE',
  'E',
  'SE',
  'S',
  'SW',
  'W',
  'NW',
];

Set<String>? _directionsOption(Parsed parsed, String name) {
  final value = parsed.options[name];
  if (value == null) {
    return null;
  }

  final chosen = <String>{};
  for (final direction in value.split(',')) {
    if (!_directions.contains(direction)) {
      throw Failure(
        2,
        'option --$name needs directions from ${_directions.join(',')}, '
        'got $value',
      );
    }
    if (!chosen.add(direction)) {
      throw Failure(2, 'option --$name lists $direction twice');
    }
  }
  return chosen;
}

String nearCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['only', 'except']);
  parsed.expect(1, 'near CODE [--only DIRS | --except DIRS]');
  if (parsed.options.containsKey('only') &&
      parsed.options.containsKey('except')) {
    throw Failure(2, 'options --only and --except cannot be combined');
  }
  final only = _directionsOption(parsed, 'only');
  final except = _directionsOption(parsed, 'except');

  final output = StringBuffer();
  for (final (name, code) in geohashNeighbors(parsed.positionals[0])) {
    if ((only == null || only.contains(name)) &&
        (except == null || !except.contains(name))) {
      output.write('$name $code\n');
    }
  }
  return output.toString();
}
