import 'package:app/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

// TODO Classe AuthViewModel mockada para construção das telas
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Atributos
  bool _loading = false;
  UserVo? _user;
  String? _errorMessage;

  // Gets
  UserVo? get user => _user;
  bool get isLoading {return _loading;}

  Future<UserVo?> doDogin(String login, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.doLogin(login, password);
      _loading = false;
      return user;
    } catch (e) {
      _errorMessage = "Erro ao fazer o login $e";
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> isAuthenticate() async {

  }



  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}