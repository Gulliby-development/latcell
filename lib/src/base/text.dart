import 'dart:convert';

import 'failure.dart';

String asciiLower(String text) {
  final units = <int>[...text.codeUnits];
  for (var index = 0; index < units.length; index++) {
    final unit = units[index];
    if (unit >= 0x41 && unit <= 0x5a) {
      units[index] = unit + 0x20;
    }
  }
  return String.fromCharCodes(units);
}

String asciiUpper(String text) {
  final units = <int>[...text.codeUnits];
  for (var index = 0; index < units.length; index++) {
    final unit = units[index];
    if (unit >= 0x61 && unit <= 0x7a) {
      units[index] = unit - 0x20;
    }
  }
  return String.fromCharCodes(units);
}

String trimBlanks(String text) {
  var start = 0;
  var end = text.length;
  while (start < end) {
    final unit = text.codeUnitAt(start);
    if (unit != 0x20 && unit != 0x09) {
      break;
    }
    start++;
  }
  while (end > start) {
    final unit = text.codeUnitAt(end - 1);
    if (unit != 0x20 && unit != 0x09) {
      break;
    }
    end--;
  }
  return text.substring(start, end);
}

String decodeUtf8(List<int> bytes, String label) {
  try {
    return const Utf8Decoder().convert(bytes);
  } on FormatException {
    throw Failure(2, '$label: input is not valid UTF-8');
  }
}

List<String> splitLines(String text) {
  final lines = <String>[];
  var start = 0;
  for (var index = 0; index < text.length; index++) {
    if (text.codeUnitAt(index) != 0x0a) {
      continue;
    }
    var end = index;
    if (end > start && text.codeUnitAt(end - 1) == 0x0d) {
      end--;
    }
    lines.add(text.substring(start, end));
    start = index + 1;
  }
  if (start < text.length) {
    lines.add(text.substring(start));
  }
  return lines;
}
