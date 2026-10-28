import '../base/options.dart';
import '../codec/geohash.dart';

String nearCommand(List<String> args) {
  final parsed = parseOptions(args, const <String>[]);
  parsed.expect(1, 'near CODE');

  final output = StringBuffer();
  for (final (name, code) in geohashNeighbors(parsed.positionals[0])) {
    output.write('$name $code\n');
  }
  return output.toString();
}
