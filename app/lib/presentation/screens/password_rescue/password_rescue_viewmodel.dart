import 'package:app/repositories/auth_repository.dart';
import 'package:flutter/cupertino.dart';

import 'package:app/core/typedefs/typedefs.dart';

class PasswordRescueViewmodel extends ChangeNotifier {
  final FailureMessageMapper _failureMessageMapper;
  final AuthRepository _authRepository;

  bool _loading = false;
  bool isSuccessPasswordRescue = false;
  Object? _errorMessage;

  bool get isLoading => _loading;
  Object? get errorMessage => _errorMessage;

  PasswordRescueViewmodel(
    this._failureMessageMapper,
    this._authRepository
  );

  Future<void> doPasswordRescue(String email) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final resultRequest = await _authRepository.passwordRescueRequest(email);

    resultRequest.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
        isSuccessPasswordRescue = false;
      },
      (success) {
        isSuccessPasswordRescue = true;
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
