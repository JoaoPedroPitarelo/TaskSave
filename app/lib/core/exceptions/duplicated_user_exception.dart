class DuplicatedUserException implements Exception {
  final String message;

  const DuplicatedUserException(this.message);

  @override
  String toString() {
    return message;
  }
}