import 'package:app/domain/models/user_vo.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  UserVo? _user;

  bool get isAuthenticated => _isAuthenticated;
  UserVo? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    final isAuthenticated = await _authService.isAuthenticated();
    _isAuthenticated = isAuthenticated;
    _user = _authService.currentUser;

    notifyListeners();
    _isLoading = false;
  }

  void setLoggedIn(UserVo user) {
    _isAuthenticated = true;
    _user = user;
    print('AuthProvider DEBUG: setLoggedIn chamado. _isAuthenticated AGORA É: $_isAuthenticated');
    notifyListeners();
    print('AuthProvider DEBUG: notifyListeners() DISPARADO.');
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}