import 'package:app/services/auth_service.dart';
import 'package:app/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final secureStorage = FlutterSecureStorage();
  final authService = AuthService(); // Só para testes

  Future<String> getInitialRoute() async {
    await authService.doLogin('gclp2004@gmail.com', 'Password123!'); // só para testes, isso aqui vai ocorrer na tela de login
    final token = await secureStorage.read(key: "jwtUser");

    print(token);

    if (token != null) {
      return "/home";
    } else {
      return "/login";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              showSemanticsDebugger: false,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: [
                Locale('en'),
                Locale('pt')
              ],
              locale: Locale('pt'),
              initialRoute: '/welcomeScreen1',// snapshot.data!, 
              routes: AppRoutes.routes,
            );
          } else {
            return Text("Erro"); // TODO fazer tela de erro
          }
        });
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
