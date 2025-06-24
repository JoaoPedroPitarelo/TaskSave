import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/services/auth_api_dio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthApiDioService _authApiDioService;
  final FailureMessageMapper _failureMessageMapper;

  RegisterViewModel(this._failureMessageMapper, this._authApiDioService, );

  bool _loading = false;
  Object? _errorMessage;
  bool _isUserCreated = false;

  Object? get errorMessage => _errorMessage;
  bool get isLoading => _loading;
  bool get isUserCreated => _isUserCreated;

  set isUserCreated(bool isUserCreated) {
    _isUserCreated = isUserCreated;
  }

  Future<void> createLogin(String login, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authApiDioService.registerRequest(login, password);
 
    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
        _isUserCreated = false;
      },
      (userInfo) {
        _isUserCreated = true;
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
