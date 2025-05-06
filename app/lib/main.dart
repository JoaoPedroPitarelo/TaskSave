import 'package:app/services/auth_service.dart';
import 'package:app/utils/app_routes.dart';
import 'package:app/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: Providers.providersList, 
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authService = AuthService(); 


  Future<String> getInitialRoute() async {
    // TODO Desfazendo o login para trabalhar na tela de login
    authService.logout();

    if (await authService.isAuthenticated()) {
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
              // TODO Jogar o tema do app para outro arquivo
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 61, 64, 254)),
                fontFamily: GoogleFonts.roboto.toString(),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    )
                  ),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              themeMode: ThemeMode.dark,
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
              initialRoute: '/login', //snapshot.data,   
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
