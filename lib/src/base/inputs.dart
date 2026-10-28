import 'failure.dart';
import 'text.dart';

class Inputs {
  const Inputs({required this.stdin, required this.file});

  final Future<List<int>> Function() stdin;
  final List<int>? Function(String path) file;

  Future<(String, String)> read(String name) async {
    if (name == '-') {
      const label = '<stdin>';
      final bytes = await stdin();
      return (label, decodeUtf8(bytes, label));
    }

    final bytes = file(name);
    if (bytes == null) {
      throw Failure(2, 'cannot read $name');
    }
    return (name, decodeUtf8(bytes, name));
  }
}
