import '../base/failure.dart';
import '../base/options.dart';
import '../codec/systems.dart';

String convertCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>['to', 'length', 'system']);
  parsed.expect(1, 'convert CODE --to SYSTEM [--length N] [--system SYSTEM]');

  if (!parsed.options.containsKey('to')) {
    throw const Failure(2, 'option --to is required');
  }
  final target = systemOption(parsed, 'to');
  if (target == null) {
    throw const Failure(2, 'option --to is required');
  }
  final source = systemOption(parsed, 'system');
  final located = decodeIn(parsed.positionals[0], source);
  final length = parsed.intOption('length') ?? defaultLength(target);
  return '${encodeIn(target, located.decoded.cell.centerLat, located.decoded.cell.centerLon, length)}\n';
}
