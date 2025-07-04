import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/domain/events/auth_events.dart';
import 'package:app/repositories/auth_repository.dart';
import 'package:app/services/events/auth_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthEventService _authEventService = AuthEventService();

  final AuthRepository _authRepository;
  final FailureKey Function(Failure) _mapFailureKey;

  RegisterViewModel(this._mapFailureKey, this._authRepository, );

  bool _loading = false;
  FailureKey? _errorKey;

  Object? get errorKey => _errorKey;
  bool get isLoading => _loading;

  Future<void> createLogin(String login, String password) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _authRepository.registerRequest(login, password);
 
    result.fold(
      (failure) {
        _errorKey = _mapFailureKey(failure);
        _authEventService.add(RegisterEvent(success: false, failureKey: _errorKey));
      },
      (userInfo) {
        _authEventService.add(RegisterEvent(success: true));
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
