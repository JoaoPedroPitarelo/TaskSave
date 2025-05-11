class UserNotVerifiedException implements Exception{
  final String message;

  const UserNotVerifiedException(this.message);

  @override
  String toString() {
    return message;
  }
}