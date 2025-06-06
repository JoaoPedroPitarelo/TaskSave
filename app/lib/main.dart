import 'package:app/core/themes/app_theme_data.dart';
import 'package:app/presentation/views/theme_provider.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), 
      child: MyApp(),
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
            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                  theme: AppThemeData.lightTheme,
                  darkTheme: AppThemeData.darkTheme,
                  themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
                  debugShowCheckedModeBanner: false,
                  showSemanticsDebugger: false,
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate
                  ],
                  supportedLocales: [
                    //Locale('en'),
                    Locale("pt")
                  ],
                  locale: Locale("pt"),
                  initialRoute: "/welcomeScreen2", //snapshot.data,   
                  routes: AppRoutes.routes,
                );
              },
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
