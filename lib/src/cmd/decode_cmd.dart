import '../base/options.dart';
import '../codec/systems.dart';

String decodeCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['system']);
  parsed.expect(1, 'decode CODE [--system SYSTEM]');

  final system = systemOption(parsed, 'system');
  final located = decodeIn(parsed.positionals[0], system);
  final cell = located.decoded.cell;
  return 'system: ${located.system}\n'
      'code: ${located.decoded.code}\n'
      'lat: ${cell.latLo.toFixed(7)} .. ${cell.latHi.toFixed(7)}\n'
      'lon: ${cell.lonLo.toFixed(7)} .. ${cell.lonHi.toFixed(7)}\n'
      'center: ${cell.centerLat.toFixed(7)}, ${cell.centerLon.toFixed(7)}\n';
}
