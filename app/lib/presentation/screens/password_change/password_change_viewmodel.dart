import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/events/auth_events.dart';
import 'package:app/repositories/api/auth_repository.dart';
import 'package:app/services/events/auth_event_service.dart';
import 'package:flutter/material.dart';

class PasswordResetViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FailureKey Function(Failure) _mapFailureKey;

  final AuthEventService _authEventService = AuthEventService();

  PasswordResetViewmodel(
    this._authRepository,
    this._mapFailureKey,
  );

  bool _loading = false;
  FailureKey? _errorKey;

  bool get isLoading => _loading;
  FailureKey? get errorKey => _errorKey;

  @override
  void dispose() {
    _authEventService.dispose();
    super.dispose();
  }

  Future<void> resetPassword(String rescueToken, String newPassword) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _authRepository.passwordChangeRequest(rescueToken, newPassword);
  
    result.fold(
      (failure) {
        _errorKey = _mapFailureKey(failure);
        _authEventService.add(PasswordResetedEvent(success: false, failureKey: errorKey));
      }, 
      (success) {
        _authEventService.add(PasswordResetedEvent(success: true));
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
