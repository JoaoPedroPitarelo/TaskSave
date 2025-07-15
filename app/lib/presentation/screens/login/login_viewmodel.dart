import 'package:app/core/errors/failure.dart';
import 'package:app/core/errors/failure_keys.dart';
import 'package:app/core/events/auth_events.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/events/auth_event_service.dart';
import 'package:flutter/material.dart';

import 'package:app/repositories/api/auth_repository.dart';

class LoginViewmodel extends ChangeNotifier {
  final AuthService _authService;
  final AuthRepository _authRepository;
  final AuthProvider _authProvider;
  final FailureKey Function(Failure) _mapFailureKey;

  final AuthEventService _authEventService = AuthEventService();

  bool _loading = false;
  FailureKey? _errorKey;

  Object? get errorKey => _errorKey;
  bool get isLoading => _loading;

  LoginViewmodel(
    this._authService,
    this._authRepository,
    this._authProvider,
    this._mapFailureKey
  );

  Future<void> doLogin(String email, String password) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();

    final result = await _authRepository.loginRequest(email, password);

    result.fold(
      (failure) {
        _errorKey = _mapFailureKey(failure);
        _authEventService.add(LoginEvent(success: false, failureKey: _errorKey));
        _loading = false;
        notifyListeners();
      },
      (userInfo) async {
        final token = userInfo['accessToken'];
        final refreshToken = userInfo['refreshToken'];
        final userId = userInfo['user']["id"].toString();
        final userEmail = userInfo['user']["email"];

        await _authService.saveAuthInfo(token, refreshToken, UserVo(id: userId, login: userEmail));

        _authProvider.setLoggedIn(UserVo(id: userId, login: email));

        _loading = false;
        _authEventService.add(LoginEvent(success: true));
        notifyListeners();
      }
    );
  }

  void clearError() {
    _errorKey = null;
    notifyListeners();
  }
}