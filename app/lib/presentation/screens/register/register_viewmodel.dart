import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:app/services/auth_api_dio_service.dart';
import 'package:app/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthApiDioService _authApiDioService;
  final FailureMessageMapper _failureMessageMapper;

  RegisterViewModel(this._failureMessageMapper, this._authApiDioService, );

  bool _loading = false;
  Object? _errorMessage;
  bool userCreated = false;

  Object? get error => _errorMessage;
  bool get isLoading => _loading;

  Future<void> createLogin(String login, String password, String confirmedPassword) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authApiDioService.registerRequest(login, password);
 
    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
      },
      (userInfo) {
        userCreated = true;
      }
    );

    _loading = false;
    notifyListeners();    
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}