import 'dart:async';

import 'package:app/services/auth_api_dio_service.dart';
import 'package:dio/dio.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/presentation/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final AuthProvider _authProvider;
  final AuthApiDioService _authApiDioService;
  final Dio _dio;
  static const List<String> authEndpointsToExclude = [
    '/login',
    '/login/create',
    'login/rescue'
  ];

  bool _isRefreshing = false;
  late Completer<Response<dynamic>> _refreshTokenCompleterStack;

  AuthInterceptor(this._authApiDioService ,this._authService, this._authProvider, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_authService.authToken != null) {
      options.headers["Authorization"] = "Bearer ${_authService.authToken}";
    }

    options.headers["Content-Type"] = "application/json";
    options.headers["Accept"] = "application/json";

    super.onRequest(options, handler);
  }

 @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    final requestPath = err.requestOptions.path;

    final bool isAuthEndPoint = authEndpointsToExclude.any(
      (endpoint) => requestPath.contains(endpoint)
    );

    if (isAuthEndPoint) {
      print('AuthInterceptor: 401 em endpoint de autenticação (${requestPath}). Não tentando refresh, passando erro adiante.');
      return handler.next(err);
    }

    if (_isRefreshing) {
      print('AuthInterceptor: Já em processo de refresh. Enfileirando requisição.');
      try {
        final newResponse = await _refreshTokenCompleterStack.future;
        return handler.resolve(newResponse);
      } catch (e) {
        return handler.next(err);
      }
    }

    await _handleTokenRefresh(err, handler);
  }

 
  Future<void> _handleTokenRefresh(DioException err, ErrorInterceptorHandler handler) async {
    _isRefreshing = true;
    _refreshTokenCompleterStack = Completer<Response<dynamic>>();

    print('AuthInterceptor: Access Token expirado (401). Tentando refresh...');

    final currentRefreshToken = _authService.refreshToken;

    if (currentRefreshToken == null) {
      print('AuthInterceptor: No refresh token available. Forçando logout.');
      return _forceLogout(err, handler); 
    }

    try {
      final refreshResult = await _authApiDioService.refreshTokenRequest(currentRefreshToken);

      await refreshResult.fold(
        (failure) async {
          print('AuthInterceptor: Refresh Token falhou: ${failure}. Forçando logout.');
          return _forceLogout(err, handler);
        },
        (newTokens) async {
          final newAccessToken = newTokens['accessToken'] as String;
          final newRefreshToken = newTokens['refreshToken'] as String;
          final currentUser = _authService.currentUser;

          if (currentUser == null) {
            print('AuthInterceptor: Refresh succeeded but no current user data. Forcing logout.');
            return _forceLogout(err, handler);
          }

          await _authService.saveAuthInfo(newAccessToken, newRefreshToken, currentUser);
          print('AuthInterceptor: Tokens refreshed and saved successfully.');

          await _proceedRequestWithNewToken(err.requestOptions, newAccessToken, handler);
        },
      );
    } catch (e) {
      print('AuthInterceptor: Erro inesperado ao tentar refresh token: $e');
      return _forceLogout(err, handler);
    } finally {
      _isRefreshing = false;
    }
  }

  
  Future<void> _proceedRequestWithNewToken(
      RequestOptions originalRequest, String newAccessToken, ErrorInterceptorHandler handler) async {
    originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final response = await _dio.fetch(originalRequest);
      _refreshTokenCompleterStack.complete(response);
      handler.resolve(response); 
    } on DioException catch (e) { 
      _refreshTokenCompleterStack.completeError(e);
      handler.next(e);
    }
  }

  Future<void> _forceLogout(DioException err, ErrorInterceptorHandler handler) async {
    await _authService.clearAuthData();
    _authProvider.logout();
    _refreshTokenCompleterStack.completeError(err); 
    handler.next(err);
    _isRefreshing = false;
  }
}
