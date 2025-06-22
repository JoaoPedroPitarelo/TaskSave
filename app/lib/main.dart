import 'package:app/core/themes/dark/app_theme_data_dark.dart';
import 'package:app/core/themes/light/app_theme_data_light.dart';
import 'package:app/core/utils/auth_interceptor.dart';

import 'package:app/presentation/providers/auth_provider.dart';
import 'package:app/presentation/providers/theme_provider.dart';
import 'package:app/presentation/screens/wrapper.dart';

import 'package:app/services/auth_api_dio_service.dart';
import 'package:app/services/auth_service.dart';

import 'package:app/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.init();
  await authService.clearAuthData();

  runApp(MultiProvider(
    providers: [
      Provider<AuthService>(
          create: (context) => authService,
          lazy: false
      ),
      ChangeNotifierProvider(
          create: (context) {
            final authService = context.read<AuthService>();
            return AuthProvider(authService);
          }
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      Provider<Dio>(
        create: (context) {
          return Dio(
              BaseOptions(
                  baseUrl: 'http://10.0.0.9:8080',
                  connectTimeout: const Duration(seconds: 20),
                  receiveTimeout: const Duration(seconds: 10)
              )
          );
        },
      ),
      Provider<AuthApiDioService>(
        create: (context) => AuthApiDioService(
          Provider.of<Dio>(context, listen: false),
        ),
      ),
    ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = Provider.of<Dio>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authApiDioService = Provider.of<AuthApiDioService>(context, listen: false);

      dio.interceptors.add(AuthInterceptor(
        authApiDioService,
        authService,
        authProvider,
        dio,
      ));

      authProvider.addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    Provider.of<AuthProvider>(context, listen: false).removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      navigatorKey.currentState?.popUntil((screen) => screen.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppThemeDataLight.lightTheme,
      darkTheme: AppThemeDataDark.darkTheme,
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
      home: Wrapper(),
    );
  }
}
