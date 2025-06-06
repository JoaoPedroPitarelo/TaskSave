import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';


class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FailureMessageMapper _failureMessageMapper;

  LoginViewModel(this._authService, this._failureMessageMapper);

  // Atributos
  bool _loading = false;
  UserVo? _user;
  Object? _errorMessage;

  // Gets
  UserVo? get user => _user;
  Object? get errorMessage => _errorMessage;
  bool get isLoading {return _loading;}

  Future<void> doLogin(String login, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.doLogin(login, password);

    result.fold(
      // Left - falha/caminho ruim
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
      }, 
      // Right - sucesso/caminho bom
      (userVo) {
        _user = userVo;
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