import 'package:task_save/core/errors/failure.dart';
import 'package:task_save/core/errors/failure_keys.dart';
import 'package:task_save/core/events/auth_events.dart';
import 'package:task_save/repositories/api/auth_repository.dart';
import 'package:task_save/services/events/auth_event_service.dart';
import 'package:flutter/cupertino.dart';

class PasswordRescueViewmodel extends ChangeNotifier {
  final AuthEventService _authEventService = AuthEventService();

  final FailureKey Function(Failure) _mapFailureToKey;
  final AuthRepository _authRepository;

  bool _loading = false;
  FailureKey? _errorKey;

  bool get isLoading => _loading;
  FailureKey? get errorKey => _errorKey;

  PasswordRescueViewmodel(
    this._mapFailureToKey,
    this._authRepository
  );

  Future<void> doPasswordRescue(String email) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final resultRequest = await _authRepository.passwordRescueRequest(email);

    resultRequest.fold(
      (failure) {
        _errorKey = _mapFailureToKey(failure);
        _authEventService.add(PasswordRescueEvent(success: false, failureKey: errorKey));
      },
      (success) {
        _authEventService.add(PasswordRescueEvent(success: true));
      }
    );

    _loading = false;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorKey = null;
    notifyListeners();
  }
}
