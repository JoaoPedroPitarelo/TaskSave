import 'package:app/core/typedefs/typedefs.dart';
import 'package:app/domain/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FailureMessageMapper _failureMessageMapper;

  RegisterViewModel(this._authService, this._failureMessageMapper);

  // Atributos
  bool _loading = false;
  UserVo? _user;
  Object? _errorMessage;

  // Gets
  UserVo? get user => _user;
  Object? get error => _errorMessage;
  bool get isLoading => _loading;

  Future<void> createLogin(String login, String password, String confirmedPassword) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners(); // notificar os ouvintes

    final result = await _authService.createLogin(login, password, confirmedPassword);
 
    result.fold(
      (failure) {
        _errorMessage = _failureMessageMapper(failure);
      },
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