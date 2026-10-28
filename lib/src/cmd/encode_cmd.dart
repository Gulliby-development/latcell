import '../base/failure.dart';
import '../base/options.dart';
import '../codec/systems.dart';
import '../num/decimal.dart';

String encodeCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['length']);
  parsed.expect(3, 'encode SYSTEM LAT LON [--length N]');

  final system = parsed.positionals[0];
  if (!systemNames.contains(system)) {
    throw Failure(2, 'unknown system $system');
  }

  final length = parsed.intOption('length') ?? defaultLength(system);
  checkLength(system, length);
  final latitude = parseLat(parsed.positionals[1]);
  final longitude = parseLon(parsed.positionals[2]);
  return '${encodeIn(system, latitude, longitude, length)}\n';
}
