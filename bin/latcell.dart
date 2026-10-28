import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:latcell/src/base/inputs.dart';
import 'package:latcell/src/cmd/cli.dart';

Future<List<int>> _readStdin() async {
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in stdin) {
    bytes.add(chunk);
  }
  return bytes.takeBytes();
}

List<int>? _readFile(String path) {
  try {
    return File(path).readAsBytesSync();
  } on FileSystemException {
    return null;
  }
}

Future<void> main(List<String> args) async {
  final outcome = await runCli(
    args,
    Inputs(stdin: _readStdin, file: _readFile),
  );
  stdout.add(utf8.encode(outcome.out));
  stderr.add(utf8.encode(outcome.err));
  await stdout.flush();
  await stderr.flush();
  exitCode = outcome.code;
}
