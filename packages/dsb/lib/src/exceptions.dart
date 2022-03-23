class DsbException implements Exception {
  final String _message;
  DsbException([this._message = 'A DSB error has occurred.']);

  @override
  String toString() => _message;
}

class AuthenticationException extends DsbException {
  AuthenticationException(
      [String _message = 'An authentication error has occurred.'])
      : super(_message);
}
