import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/models/user_vo.dart';

abstract class AuthDataEvent {}

class AuthChangedEvent extends AuthDataEvent {
  final UserVo? user;

  AuthChangedEvent({required this.user});
}

class LoginEvent extends AuthDataEvent {
  FailureKey? failureKey;
  final bool success;

  LoginEvent({required this.success, this.failureKey});
}

class RegisterEvent extends AuthDataEvent {
  FailureKey? failureKey;
  final bool success;

  RegisterEvent({required this.success, this.failureKey});
}

class PasswordRescueEvent extends AuthDataEvent {
  FailureKey? failureKey;
  final bool success;

  PasswordRescueEvent({required this.success, this.failureKey});
}

class PasswordResetedEvent extends AuthDataEvent {
  FailureKey? failureKey;
  final bool success;

  PasswordResetedEvent({required this.success, this.failureKey});
}
