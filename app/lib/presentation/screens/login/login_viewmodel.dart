import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../services/auth_api_dio_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AuthApiDioService _authApiDioService;
  final AuthProvider _authProvider;
  final FailureMessageMapper _failureMessageMapper;

  bool _loading = false;
  Object? _errorMessage;

  Object? get errorMessage => _errorMessage;
  bool get isLoading => _loading;

  LoginViewModel(
    this._authService,
    this._authApiDioService,
    this._authProvider,
    this._failureMessageMapper
  );

  Future<void> doLogin(String email, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authApiDioService.loginRequest(email, password);

    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
        _loading = false;
        notifyListeners();
      },
      (userInfo) async {
        final token = userInfo['accessToken'];
        final refreshToken = userInfo['refreshToken'];
        final userId = userInfo['userId'].toString();

        await _authService.saveAuthInfo(token, refreshToken, UserVo(id: userId, login: email));
        print('LoginViewModel DEBUG: Dados salvos no AuthService. Chamando AuthProvider.setLoggedIn...');

        _authProvider.setLoggedIn(UserVo(id: userId, login: email));
        print('LoginViewModel DEBUG: AuthProvider.setLoggedIn() executado.');

        _loading = false;
        notifyListeners();
        print('LoginViewModel DEBUG: notifyListeners() do ViewModel disparado. Fim da operação.');
      }
    );


  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}