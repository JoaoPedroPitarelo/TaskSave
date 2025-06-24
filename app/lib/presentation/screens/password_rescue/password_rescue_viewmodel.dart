import 'package:app/services/auth_api_dio_service.dart';
import 'package:flutter/cupertino.dart';

import 'package:app/core/typedefs/typedefs.dart';

class PasswordRescueViewmodel extends ChangeNotifier {
  final FailureMessageMapper _failureMessageMapper;
  final AuthApiDioService _authApiDioService;

  bool _loading = false;
  bool isSuccessPasswordRescue = false;
  Object? _errorMessage;

  bool get isLoading => _loading;
  Object? get errorMessage => _errorMessage;

  PasswordRescueViewmodel(
    this._failureMessageMapper,
    this._authApiDioService
  );

  Future<void> doPasswordRescue(String email) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final resultRequest = await _authApiDioService.passwordRescueRequest(email);

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
