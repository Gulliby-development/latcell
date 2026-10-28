class Failure implements Exception {
  const Failure(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => message;
}
