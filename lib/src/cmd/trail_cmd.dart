import '../base/inputs.dart';
import '../base/options.dart';
import '../codec/systems.dart';
import '../geo/trail.dart';

Future<String> trailCommand(List<String> args, Inputs inputs) async {
  final parsed = parseOptions(args, const <String>['system', 'length']);
  parsed.expect(1, 'trail FILE [--system SYSTEM] [--length N]');

  final system = systemOption(parsed, 'system') ?? 'geohash';
  final length = parsed.intOption('length') ?? defaultLength(system);
  checkLength(system, length);

  final (label, text) = await inputs.read(parsed.positionals.single);
  final trail = readTrail(text, label, system, length);
  final output = StringBuffer();
  for (final run in trail.runs) {
    output.write('${run.code} ${run.count} ${run.first} ${run.last}\n');
  }
  output.write('runs: ${trail.runs.length} points: ${trail.points}\n');
  return output.toString();
}
