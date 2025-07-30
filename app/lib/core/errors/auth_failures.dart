import 'package:task_save/core/errors/failure.dart';

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();

  @override
  List<Object?> get props => [];
}

class UserNotVerifiedFailure extends Failure {
  const UserNotVerifiedFailure();

  @override
  List<Object?> get props => [];
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure();

  @override
  List<Object?> get props => [];
}

class DuplicatedEmailFailure extends Failure {
  const DuplicatedEmailFailure();

  @override
  List<Object?> get props => [];
}

class InvalidOrExpiredTokenFailure extends Failure {
  const InvalidOrExpiredTokenFailure();

  @override
  List<Object?> get props => [];
}

class PasswordsAreNotSameFailure extends Failure {
  const PasswordsAreNotSameFailure();

  @override
  List<Object?> get props => [];
}
