import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/errors/auth_failures.dart';
import 'package:task_save/core/errors/category_failures.dart';
import 'package:task_save/core/errors/task_failures.dart';

FailureKey mapFailureToKey(Failure failure) => switch (failure) {
  TaskNotFoundFailure()          => FailureKey.taskNotFound,
  CategoryNotFoundFailure()      => FailureKey.categoryNotFound,
  DuplicatedEmailFailure()       => FailureKey.duplicatedUser,
  InvalidCredentialsFailure()    => FailureKey.invalidCredentials,
  InvalidOrExpiredTokenFailure() => FailureKey.invalidToken,
  UserNotVerifiedFailure()       => FailureKey.userNotVerified,
  UserNotFoundFailure()          => FailureKey.userNotFound,
  NoConnectionFailure()          => FailureKey.connectionServerError,
  ServerFailure()                => FailureKey.generalServerError,
  PasswordsAreNotSameFailure()   => FailureKey.passwordAreNotTheSame,
  UnexpectedFailure()            => FailureKey.generalUnexpectedError,
  _                              => FailureKey.generalUnexpectedError,
};
