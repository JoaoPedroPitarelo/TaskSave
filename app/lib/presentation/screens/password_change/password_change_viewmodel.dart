import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class PasswordResetViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FailureMessageMapper _failureMessageMapper;

  PasswordResetViewmodel(
    this._authRepository,
    this._failureMessageMapper,
  );

  bool _loading = false;
  Object? _errorMessage;
  bool isPasswordReseted = false;

  bool get isLoading => _loading;
  Object? get errorMessage => _errorMessage;

  Future<void> resetPassword(String rescueToken, String newPassword) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.passwordChangeRequest(rescueToken, newPassword);
  
    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
        isPasswordReseted = false;
      }, 
      (success) {
        isPasswordReseted = true;
      }
    );

    _loading = false;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
