import '../base/failure.dart';
import '../base/inputs.dart';
import '../base/output.dart';
import 'convert_cmd.dart';
import 'cover_cmd.dart';
import 'decode_cmd.dart';
import 'encode_cmd.dart';
import 'near_cmd.dart';
import 'trail_cmd.dart';

const String version = '0.1.0';
const String usageText =
    'usage: latcell COMMAND [ARGS]\n'
    'commands:\n'
    '  encode SYSTEM LAT LON [--length N]\n'
    '  decode CODE [--system SYSTEM]\n'
    '  convert CODE --to SYSTEM [--length N] [--system SYSTEM]\n'
    '  near CODE\n'
    '  cover --box S,W,N,E --length N [--limit M]\n'
    '  trail FILE [--system SYSTEM] [--length N]\n'
    'systems: geohash, maidenhead, olc, georef\n';

Future<Outcome> runCli(List<String> args, Inputs inputs) async {
  if (args.isEmpty) {
    return const Outcome(2, '', usageText);
  }

  final command = args.first;
  if (command == 'help' || command == '--help') {
    return const Outcome(0, usageText, '');
  }
  if (command == '--version') {
    return const Outcome(0, 'latcell 0.1.0\n', '');
  }

  final commandArgs = args.skip(1).toList();
  try {
    final output = switch (command) {
      'encode' => encodeCommand(commandArgs),
      'decode' => decodeCommand(commandArgs),
      'convert' => convertCommand(commandArgs),
      'near' => nearCommand(commandArgs),
      'cover' => coverCommand(commandArgs),
      'trail' => await trailCommand(commandArgs, inputs),
      _ => throw Failure(2, 'unknown command $command'),
    };
    return Outcome(0, output, '');
  } on Failure catch (failure) {
    return Outcome(failure.code, '', 'latcell: ${failure.message}\n');
  }
}
