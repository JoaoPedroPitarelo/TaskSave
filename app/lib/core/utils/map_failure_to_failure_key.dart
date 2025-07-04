import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/exceptions/auth_failures.dart';
import 'package:app/domain/exceptions/category_failures.dart';

FailureKey mapFailureToKey(Failure failure) => switch (failure) {
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