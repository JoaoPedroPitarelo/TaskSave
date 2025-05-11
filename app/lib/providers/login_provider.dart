import 'package:app/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';


class LoginProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Atributos
  bool _loading = false;
  UserVo? _user;
  Object? _error;

  // Gets
  UserVo? get user => _user;
  Object? get error => _error;
  bool get isLoading {return _loading;}

  Future<UserVo?> doLogin(String login, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.doLogin(login, password);
      _user = user;
      _loading = false;
      return user;
    } catch (e) {
      _error = e;
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}