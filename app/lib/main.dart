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
    final token = await secureStorage.read(key: "jwtUser");

    if (token != null) {
      return "/home";
    } else {
      return "/welcomeScreen1";
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
              locale: Locale('en'),
              initialRoute: snapshot.data,   
              routes: AppRoutes.routes,
            );
          } else {
            return Text("Erro"); // TODO fazer tela de erro
          }
        });
  }
}

// TODO melhorar isso aqui
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
