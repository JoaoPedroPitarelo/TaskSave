import 'package:app/core/exceptions/passwords_are_not_same_exception.dart';
import 'package:app/models/user_vo.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Atributos
  bool _loading = false;
  UserVo? _user;
  Object? _error;

  // Gets
  UserVo? get user => _user;
  Object? get error => _error;
  bool get isLoading => _loading;

  Future<UserVo?> createLogin(String login, String password, String confirmedPassword) async {
    _loading = true;
    _error = null;
    notifyListeners(); // notificar os ouvintes

    try {
      if (password != confirmedPassword) {
        throw PasswordsAreNotSameException("The passwords are not the same");
      }
      final user = await _authService.createLogin(login, password);
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