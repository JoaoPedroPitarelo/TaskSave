class PasswordsAreNotSameException implements Exception{
  final String message;

  const PasswordsAreNotSameException(this.message);

  @override
  String toString() {
    return message;
  }
}