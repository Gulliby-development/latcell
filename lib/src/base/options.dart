import 'failure.dart';

class Parsed {
  const Parsed(this.positionals, this.options);

  final List<String> positionals;
  final Map<String, String> options;

  int? intOption(String name) {
    final value = options[name];
    if (value == null) {
      return null;
    }

    if (value.isEmpty || value.length > 6) {
      throw Failure(2, 'option --$name needs a whole number, got $value');
    }
    for (final unit in value.codeUnits) {
      if (unit < 0x30 || unit > 0x39) {
        throw Failure(2, 'option --$name needs a whole number, got $value');
      }
    }
    return int.parse(value);
  }

  void expect(int count, String usage) {
    if (positionals.length != count) {
      throw Failure(2, 'usage: latcell $usage');
    }
  }
}

Parsed parseOptions(List<String> args, List<String> flags) {
  final positionals = <String>[];
  final options = <String, String>{};
  var parsingOptions = true;

  for (var index = 0; index < args.length; index++) {
    final argument = args[index];
    if (!parsingOptions) {
      positionals.add(argument);
      continue;
    }
    if (argument == '--') {
      parsingOptions = false;
      continue;
    }
    if (!argument.startsWith('--')) {
      positionals.add(argument);
      continue;
    }

    final equalsIndex = argument.indexOf('=');
    final name = equalsIndex < 0
        ? argument.substring(2)
        : argument.substring(2, equalsIndex);
    if (!flags.contains(name)) {
      throw Failure(2, 'unknown option --$name');
    }
    if (options.containsKey(name)) {
      throw Failure(2, 'option --$name given twice');
    }

    String value;
    if (equalsIndex >= 0) {
      value = argument.substring(equalsIndex + 1);
    } else if (index + 1 < args.length && !args[index + 1].startsWith('--')) {
      index++;
      value = args[index];
    } else {
      throw Failure(2, 'option --$name needs a value');
    }
    options[name] = value;
  }

  return Parsed(positionals, options);
}
