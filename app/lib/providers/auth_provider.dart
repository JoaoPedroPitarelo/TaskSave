import 'package:app/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Atributos
  bool _loading = false;
  UserVo? _user;
  String? _errorMessage;

  // Gets
  UserVo? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading {return _loading;}

  Future<UserVo?> doLogin(String login, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.doLogin(login, password);
      _user = user;
      _loading = false;
      return user;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}