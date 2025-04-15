import 'package:app/models/User_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

// TODO Classe AuthViewModel mockada para construção das telas
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Atributos
  UserVo? _user;
  bool _loading = false; 

  // Gets
  UserVo? get user => _user;
  bool get isAuthenticate => _user != null;
  bool get isLoading {return _loading;}

  Future<bool> doDogin(String login, String password) async {
    _loading = true;
    notifyListeners();

    final user = await _authService.doLogin(login, password);
    _loading = false;

    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }
}