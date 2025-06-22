import 'dart:async';
import 'package:app/domain/models/user_vo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  final _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = "accessToken";
  static const String _refreshTokenKey = "refreshToken";
  static const String _userIdKey = "userId";
  static const String _userEmailKey = "userEmail";

  String? _authToken;
  String? _refreshToken;
  UserVo? _currentUser;

  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;
  UserVo? get currentUser => _currentUser;

  Future<void> init() async {
    _authToken = await _secureStorage.read(key: _tokenKey);
    _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    _currentUser = UserVo(
        id: await _secureStorage.read(key: _userIdKey),
        login: await _secureStorage.read(key: _userEmailKey)
    );
  }

  Future<void> _saveTokensInSecureStorage(String token, String refreshToken, String userId) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<void> _deleteTokensInSecureStorage() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  Future<void> saveAuthInfo(String token, String refreshToken, UserVo user) async {
    _authToken = token;
    _refreshToken = refreshToken;
    _currentUser = user;
    await _saveTokensInSecureStorage(_authToken!, _refreshToken!, user.id!);
    print("saveAuthInfo chamado");
  }

  Future<void> clearAuthData() async {
    _authToken = null;
    _refreshToken = null;
    _currentUser = null;
   await _deleteTokensInSecureStorage();
  }

  Future<bool> isAuthenticated() async {
    if (_refreshToken == null) {
      await init();
    }
    print("isAuthenticaded chamado");
    return _refreshToken != null;
  }
}
