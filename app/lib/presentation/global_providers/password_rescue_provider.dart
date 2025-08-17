import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';

class PasswordRescueProvider extends ChangeNotifier {
  final _appLinks = AppLinks();
  StreamSubscription? _appLinkSubscription;

  String? _pendingRescueToken;
  String? get pendingRescueToken => _pendingRescueToken;

  PasswordRescueProvider() {
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('DeepLinkProvider: Erro ao iniciar o AppLinks: $e');
    }

    _appLinkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (error) {
      print('DeepLinkProvider: Erro ao escutar o AppLinks: $error');
    });
  }

  void _handleDeepLink(Uri uri) {
    print("DeepLinkProvider: Link recebido: $uri");
    if (uri.scheme != 'tasksave' || uri.host != 'rescue-login') {
      return;
    }

    final passwordRescueToken = uri.queryParameters['token'];
    if (passwordRescueToken == null) {
      return;
    }

    _pendingRescueToken = passwordRescueToken;
    notifyListeners();
  }

  void clearRescueToken() {
    _pendingRescueToken = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _appLinkSubscription?.cancel();
    super.dispose();
  }
}