class InvalidStateException implements Exception {
  final String invalidState;
  InvalidStateException(Object object) : invalidState = object.toString();
}
