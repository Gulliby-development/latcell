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

Set<String>? _onlyOption(Parsed parsed) {
  final value = parsed.options['only'];
  if (value == null) {
    return null;
  }

  final chosen = <String>{};
  for (final name in value.split(',')) {
    if (!_directions.contains(name)) {
      throw Failure(
        2,
        'option --only needs directions from ${_directions.join(',')}, '
        'got $value',
      );
    }
    if (!chosen.add(name)) {
      throw Failure(2, 'option --only lists $name twice');
    }
  }
  return chosen;
}

String nearCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['only']);
  parsed.expect(1, 'near CODE [--only DIRS]');
  final only = _onlyOption(parsed);

  final output = StringBuffer();
  for (final (name, code) in geohashNeighbors(parsed.positionals[0])) {
    if (only == null || only.contains(name)) {
      output.write('$name $code\n');
    }
  }
  return output.toString();
}
