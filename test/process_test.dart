import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('rejects bad UTF-8 on standard input', () async {
    final process = await Process.start(Platform.resolvedExecutable, [
      'bin/latcell.dart',
      'trail',
      '-',
    ]);
    process.stdin.add([0x31, 0x2C, 0x32, 0x0A, 0xFF, 0x0A]);
    await process.stdin.close();
    final out = await process.stdout.transform(utf8.decoder).join();
    final err = await process.stderr.transform(utf8.decoder).join();
    final code = await process.exitCode;
    expect(out, equals(''));
    expect(err, equals('latcell: <stdin>: input is not valid UTF-8\n'));
    expect(code, equals(2));
  });
}
